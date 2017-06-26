# Attachings API

## Create attaching

```
POST http://gobierto.example/admin/attachments/api/attachings
```

You'll need to provide the following parameters inside the request body, formatted as JSON:

| Paramter          | Description | Accepted values |
| ----------------- | ----------- | --------------- |
| `attachment_id`   | ID of attachment        | |
| `attachable_id`   | ID of attachable        | |
| `attachable_type` | Attachable type (class) | `'GobiertoCms::Page'` |

Example:

```json
{
    "attachment_id": 1,
    "attachable_id": 2,
    "attachable_type": "GobiertoCms::Page"
}
```

## Delete attaching

```
DELETE http://gobierto.example/admin/attachments/api/attachings
```

You'll need to provide the following parameters inside the request body, formatted as JSON:

| Paramter          | Description | Accepted values |
| ----------------- | ----------- | --------------- |
| `attachment_id`   | ID of attachment        | |
| `attachable_id`   | ID of attachable        | |
| `attachable_type` | Attachable type (class) | `'GobiertoCms::Page'` |
