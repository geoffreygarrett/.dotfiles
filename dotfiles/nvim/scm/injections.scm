;; Inject SQL into JavaScript/TypeScript using "// language=sql"
(
  (template_string
    (comment) @_comment (#match? @_comment "^// language=sql")
  ) @sql
)

;; Inject Shell script into JavaScript/TypeScript using "// language=sh"
(
  (template_string
    (comment) @_comment (#match? @_comment "^// language=sh")
  ) @bash
)

;; Inject HTML into JavaScript/TypeScript using "// language=html"
(
  (template_string
    (comment) @_comment (#match? @_comment "^// language=html")
  ) @html
)

;; Inject SQL into Shell using "# language=sql"
(
  (string
    (comment) @_comment (#match? @_comment "^# language=sql")
  ) @sql
)

;; Inject HTML into a file with HTML comments "<!-- language=html -->"
(
  (text
    (comment) @_comment (#match? @_comment "^<!-- language=html -->")
  ) @html
)

