# Firestore Data Model — Articles Backend

## Collection
- **Name:** `articles`

## Document ID Strategy
- **Type:** Firestore document ID (auto-generated or provided by backend)
- **Format:** String, lowercase kebab or UUID acceptable; must be unique per article.

## Schema (fields in each `articles/{articleId}` document)
| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `title` | string (1–140 chars) | yes | Primary headline shown in feeds and detail pages. |
| `content` | string | yes | Full article body (rich text serialized as plain/markdown HTML as needed). |
| `author` | map | yes | Embedded author info for immutable byline. |
| `author.id` | string | yes | Stable author identifier. |
| `author.name` | string | yes | Display name in byline. |
| `author.bio` | string | no | Short bio/context. |
| `author.avatarUrl` | string | no | Link to author avatar image. |
| `thumbnailUrl` | string | no | Public HTTPS URL pointing to Cloud Storage object under `media/articles/{articleId}/...`. |
| `tags` | array<string> (max 10) | no | Topical labels for filtering/search. |
| `readingTimeMinutes` | int (1–60) | yes | Precomputed read time for UX. |
| `status` | string (`draft` \| `published`) | yes | Editorial workflow state. |
| `createdAt` | timestamp | yes | Server timestamp at creation. |
| `updatedAt` | timestamp | yes | Server timestamp at last content edit. |

## Storage Layout (thumbnails)
- **Bucket path:** `media/articles/{articleId}/{filename}`
- Firestore stores only the `thumbnailUrl` string referencing this object; binary data lives in Cloud Storage.

## Design Decisions
- **Single collection** keeps queries simple and scales horizontally with Firestore’s document model.
- **Embedded author snapshot** avoids cross-collection joins at read time while preserving byline integrity even if author profile changes later.
- **Reference-only thumbnails** leverage Cloud Storage for media while keeping Firestore lean; the URL points into `media/articles`.
- **Explicit status + timestamps** support publish workflows, ordering, and cache invalidation without extra collections.
- **Controlled arrays and lengths** (e.g., tags, title) maintain predictable document size and query performance.
