shape os.vcs : os {
  type: system
  layer: 3
  """
// Shape VCS: version control derived from coherence.
//
// Every shape already has: a hash (identity), a tick (version),
// and a trace (history). Shape VCS names what already exists.
//
// Concepts:
//   commit  = dilated batch of mutations + signature snapshot
//   branch  = namespace prefix (user.ash.*, os.*, world.*)
//   log     = trace moments filtered by branch
//   diff    = shapes whose tick falls between two commits
//   merge   = overlay resolution + Law 3 conflict detection
//   push    = promotion (owner -> local -> global)
//
// Git compatibility: the `git` command translates git syntax
// to shape-vcs operations.
  """
}
