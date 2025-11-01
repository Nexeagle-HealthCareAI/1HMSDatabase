# @"

# \# easyHMS Database

# 

# \- db/deploy: CREATE tables \& indexes (idempotent)

# \- db/rollback: DROP indexes \& tables (reverse order)

# \- pipelines/\*.yml: Azure Pipelines for Dev/QA (deploy \& rollback)

# "@ | Out-File -Encoding UTF8 README.md

# 

# @"

# \# Ignore local junk

# \*.user

# \*.suo

# \*.log

# \*.tmp

# \*.bak

# \*.cache

# Thumbs.db

# Desktop.ini

# 

# \# VS/VSCode

# .vscode/

# .vs/

# 

# \# OS

# .DS\_Store

# 

# \# Tools

# .sqlpackage/

# "@ | Out-File -Encoding UTF8 .gitignore

