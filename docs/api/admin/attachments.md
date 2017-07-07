# Attachments API

## Index Attachments

Retrieves a collection of attachments.

```
GET http://gobierto.example/admin/attachments/api/attachments
```

Optional parameters:

| Paramter          | Description                                                  | Accepted values |
| ----------------- | ------------------------------------------------------------ | --------------- |
| `page`            | Used for pagination                                          | - |
| `attachable_id`   | Use combined `attachable_type` to get attachable attachments | - |
| `attachable_type` | Use combined `attachable_id` to get attachable attachments   | `'GobiertoCms::Page'` |
| `search_string`   | Provide string to search in Algolia                          | - |

## Create attachment

```
POST http://gobierto.example/admin/attachments/api/attachments
```

You'll need to provide the following parameters inside the request body, formatted as JSON (example):

```json
{
    "attachment": {
        "name": "New attachment name",
        "description": "New attachment description",
        "file_name": "sample_file.txt",
        "file": "file content encoded in base64"
    }
}
```

* Description is optional

## GET attachment

```
GET http://gobierto.example/admin/attachments/api/attachments/:id
```

You can provide the following parameters inside the request body, formatted as JSON (example):

```json
{
    "attachment": {
        "name": "New attachment name",
        "description": "New attachment description",
        "file_name": "sample_file.txt",
        "file": "file content encoded in base64"
    }
}
```

## Update attachment

```
PATCH http://gobierto.example/admin/attachments/api/attachments/:id
```

You can provide the following parameters inside the request body, formatted as JSON (example):

```json
{
    "attachment": {
        "name": "New attachment name",
        "description": "New attachment description",
        "file_name": "sample_file.txt",
        "file": "file content encoded in base64"
    }
}
```

## Delete attachment

```
DELETE http://gobierto.example/admin/attachments/api/attachments/:id
```
