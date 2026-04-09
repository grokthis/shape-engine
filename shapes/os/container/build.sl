shape os.container.build : os.container {
  type: exec
  layer: 4
  """
// container build <containerfile> [--name <name>]
//
// Build a container image from a Containerfile.
//
// Containerfile format (shape-lang, not Dockerfile):
//
//   shape my-image {
//     type: containerfile
//     (triple-quoted shape-lang)
//     from shape-engine              // base stack
//
//     env APP_ENV "production"       // set environment
//     env PORT "8080"
//
//     copy app.sl /app/              // copy shapes into image
//     copy lib/ /lib/
//
//     mount db-data /data            // declare volume mount
//
//     expose 8080                    // declare port
//
//     run "shape-lang setup.sl"      // run build command
//
//     entrypoint "app/server.sl"     // default program
//     (triple-quoted shape-lang)
//   }
//
// Unlike Dockerfile:
//   FROM -> from: selects the computation stack, not a base image.
//   COPY -> copy: copies shapes into the container's namespace.
//   RUN -> run: executes shape-lang during build.
//   No layers. No caching. No union filesystem.
//   The "image" is a shape with all its deps.
//   Building = constructing the shape with its deps resolved.
//
// What build does:
//   1. Parse the Containerfile shape.
//   2. Create image shape: os.container.images.<name>
//   3. Set stack from "from" directive.
//   4. Copy referenced shapes into image namespace.
//   5. Set environment dimensions.
//   6. Execute "run" commands in a temporary container.
//   7. Set entrypoint.
//   8. The image is ready. It's a shape.

let file = arg0
let name = default(flag("name"), arg0)

if !exists(file) {
  print("Error: containerfile " + file + " not found")
  flag
}

let img = "os.container.images." + name
add_shape(img, "container-image", content(file), 4)
print("Built image " + name + " from " + file)
  """
}
