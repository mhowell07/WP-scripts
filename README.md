WP Batch Search & Replace

A WSL- and Linux-safe WordPress batch search-and-replace utility designed for large sites.
Automatically detects table prefixes, handles large tables in chunks, and safely updates serialized values.

Features

Auto-detects WordPress table prefix (works on wp_ and custom prefixes)

Supports large databases via batch updates (prevents hangs or crashes)

Prompts for search and replacement strings

Supports dry-run mode for safe testing

Skips guid column and handles serialized PHP objects

Fully reusable across multiple sites

Requirements

WordPress site with wp-config.php

WP-CLI installed and working

Bash environment (Linux, WSL, macOS)

Installation

Copy wp-batch-search-replace.sh into the root directory of your WordPress site.

Make it executable:

chmod +x wp-batch-search-replace.sh

Usage

Run the script from your WordPress root:

./wp-batch-search-replace.sh

Steps:

Enter the string to search for (old URL, path, or value).

Enter the replacement string (new URL, path, or value).

Choose mode:

1 → Full database (recommended for migrations)

2 → Only large tables (posts, postmeta, options, usermeta)

Choose dry-run (y/n) to preview changes before committing.

The script will update:

Large tables in batches (wp_postmeta, wp_posts, wp_options, wp_usermeta)

Smaller tables normally

Examples
1. Update URLs for local development:
Search: https://example.com
Replace: http://localhost:10008
Mode: 2
Dry-run: y


Preview changes safely before running them live.

2. Change CDN host:
Search: https://cdn.oldsite.com
Replace: https://cdn.newsite.com
Mode: 1
Dry-run: n


Applies changes across the entire database in one go.

Notes & Best Practices

Always run a dry-run first to verify changes.

Make sure WP-CLI can connect to your database (check wp db check).

Large sites may take several minutes per table — batch updates prevent memory/timeouts.

If you’re using a custom table prefix, the script detects it automatically.

License

MIT License – free to use, modify, and share.
