# SCIM Demo

This is a SCIM demo server written in Rails and based on the [scimitar](https://github.com/RIPAGlobal/scimitar) gem. It comes with a Postman collection of test requests to easily see SCIM in action.

## Setup

```bash
# Start Postgres DB
docker compose up

# Initialize DB
bin/rails db:create
bin/rails db:migrate

# Start server
bin/rails s
```

To send pre-made test requests to the SCIM server, import `postman/scim.json` into your Postman App.

![Postman Request](postman/postman.png)

## About SCIM

### Use Case of SCIM

System for Cross-domain Identity Management (SCIM) is a protocol that helps systems synchronize user data between different business systems. A service provider hosts a SCIM API endpoint implementation. One or more enterprise subscribers use these APIs to let that service know about changes in the enterprise's user (employee) list. In the context of the names used by the SCIM standard, the service that is provided is some kind of software-as-a-service solution that the enterprise subscriber uses to assist with their day to day business. The enterprise maintains its user (employee) list via whatever means it wants, but includes SCIM support so that any third party services it uses can be kept up to date with adds, removals or changes to employee data.

### Specification Details

[SCIM v2 RFC 7642: Concepts](https://datatracker.ietf.org/doc/html/rfc7642) <br>
[SCIM v2 RFC 7643: Core schema](https://datatracker.ietf.org/doc/html/rfc7643) <br>
[SCIM v2 RFC 7644: Protocol](https://datatracker.ietf.org/doc/html/rfc7644) <br>

### Core Schema

Basically, you have resources like users and groups, and how they are represented in JSON is defined by a “Schema”, which itself is a JSON document, that adds some additional information to each attribute like if it is required, if it's readonly, and so on. That’s it, but some details and jargon with reference to the related RFC sections are below:

- **Schema**: SCIM manages different types of resources and they are defined by a schema URI and a resource type. The schema defines attributes, that is their name and data type. It is a JSON document, so the data types (String, Boolean, …) and structures (nesting, arrays) are what you would expect from JSON. Only special one maybe is the “Reference” type, which is a URI for a resource, like a SCIM resource, or an external link to a photo for example, or any identifier like a URN. There are also attribute characteristics associated with any attribute (Section 7) like “required”  or “mutability”, which means whether the attribute can be overwritten. There are also attribute names reserved with a special meaning (Section 2.4), for example “type”, “value”, “$ref”, “primary”, which are more or less self explanatory.
- **Schema Definition**: For each schema URI used in a resource object, there is such a corresponding “Schema” resource, which defines the attribute names, values and their characteristics.
- **Resources**: Also a JSON object (Section 3). It has a resource type,like “User”, a schema which are schema URIs that point to the schema definitions that tell you what the attribute and their characteristics are. They have common attributes that every resource has (Section 3.1): id, externalId and meta (containing resource type, created, last modified, location as the URI of the resource to be returned, optionally a version). SCIM defines resources for “User” (Section 4.1) and “Group” (Section 4.2) for example.
- **ResourceTypeSchema**: The metadata about a resource type, that is name, description, endpoint, schema, and schema extensions (Section 6).
- **Extensions**: Schemas can also be extended. You basically include the schema URI to the extension you defined, which lists all the attributes that the resource has to have additionally. I.e. “Enterprise User” is an extension of “User” and would have some additional attributes like the employee number.
- **Service Provider Configuration**: The service provider configuration (Section 5) is also a resource, so it also has its own schema URI, which just to show how it looks like is this: “urn:ietf:params:scim:schemas:core:2.0:ServiceProviderConfig”. It contains a link to a human-consumable help doc, and other than that is used to show what features of SCIM the service provides and how they are configured: Bulk operations? What filters are allowed for search queries? Supported authentication schemas?

### Protocol

As defined above we have resources like users and the SCIM protocol defines a message and response format to query those resources like a CRUD API. So we have GET, POST, PATCH, and SCIM supports filtering, sorting, paginating results, and also some query syntax to precisely state which values you want to update in the PATCH operation. Also it supports sending multiple requests at once in a bulk request. That’s it, but some more details like how such requests and responses look like are below.

- **Basics**: We have a base URI like “http://example.com/scim” and we will send requests to that endpoint to retrieve, create, modify and delete resources like users.
- **Authentication and Authorization**: It’s not specified by the SCIM standards, but think OAuth, so having a token with a scope that indicates what you are allowed to do. Note that it might be necessary to also support anonymous requests, in the case of user self registration for example.
- **Endpoints and Methods**: We talked about the “Schemas” definitions and you can retrieve them at the “/Schemas” endpoint. Similarly, the service provider config can be found at “/ServiceProviderConfig”. The SCIM messages, requests and response format, are also defined with a schema. They start with “urn:ietf:params:scim:api”, but they are not discoverable by the “/Schemas” endpoint and they are fixed. Each resource has its own endpoint, e.g., the “/Users” endpoint and then you issue CRUD operations against that endpoint (Section 3), e.g., GET /Users/<user-id>. Special endpoint is the “/Me” endpoint, which is an alias for operations against a resource mapped to the authenticated subject, you. When you query things, the attribute characteristics are considered, e.g. if they are read only, the request won’t fail but they won’t get updated either, or they can be configured to not be returned from a query, e.g., the user password. You cannot remove attributes that are required and so on.
- **Creating resources**: HTTP POST request to the resource endpoint, e.g. POST /Users (Section 3.3)
- **Retrieving resources**: If you want to retrieve a known resource, it’s simple GET /Users/<user-id>. But the SCIM protocol also defines a standard set of query parameters that can be used to filter, sort, and paginate to return zero or more resources in a query response (Section 3.4.2). The “urn:ietf:params:scim:api:messages:2.0:ListResponse” contains attributes “totalResults”, “Resources”, “startIndex”, “itemsPerPage” to support pagination. SCIM supports very complex filtering options (Section 3.4.2.2) that can be used to precisely search through the resources. Something like filter = username Eq “john”, so an attribute name followed by an operator, followed by an optional value. Operators are things like equal, starts with, greater than, and, or, and can also be applied to complex/nested attributes: filter = emails[type eq “work” and value co “@example.com” ]. For sorting (Section 3.4.2.3), there is just the “sortBy”, and “sortOrder” query parameter defined, easy. You can also control which attributes are returned, via “attributes”, and which are not, “excludedAttributes”. And clients can also query without URL parameters in case they would be sensitive, so you can use POST requests by appending “./search” to the endpoint (Section 3.4.2.5). Defined by “urn:ietf:params:scim:messages:2.0:SearchRequest”, the request now contains the above mentioned search parameters in the JSON body.
- **Replacing resources**: PUT is used to replace all resource’s attributes, but that fails if some attributes are immutable, and readOnly attributes are ignored. Required attributes have to be specified. The service responds with status 200 and the entire updated user.
- **PATCH operations**: PATCH operations (Section 3.5.2) are atomic, so if a single operation fails, an error is returned and the resource is kept at its original state. The body of an HTTP Patch request must contain the attribute “Operations” that indicate the operations to perform (add, remove, replace). And the path can also contain complex query logic like `“path”:”addresses[type eq \”work\”]`.
- **DELETE operations**: Just something like DELETE /Users/<id> basically. 
- **Bulk operations**: Enables us to send a potentially large collection of resource operations in a single request (Section 3.7). Support for bulk requests can be discovered by querying the service provider configuration. The requests and responses have some additional attributes: “failOnErrors”, the number of errors that the service provider accepts until terminating the operation and returning the response, “Operations”, each operation corresponds to a single HTTP request and they have a “method”, “bulkId”, “path”, “data”, “location”, “response”, “status”.

