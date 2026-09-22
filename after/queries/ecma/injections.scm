;; extends

((comment) @_gql_comment
  (#eq? @_gql_comment "/* GraphQL */")
  (template_string) @injection.content
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "graphql"))
