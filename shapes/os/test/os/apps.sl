shape os.test.os.apps : os.test {
  type: test
  layer: 4
  desc: "App shapes exist with routes"
  """
let apps = split("shell,browser,settings,editor", ",")
for a in apps {
  let app_id = "os.app." + a
  assert_true(exists(app_id), "app exists: " + a)
  assert_eq(dim(app_id, "type"), "app", "app has type=app: " + a)

  let route_id = "os.config.app." + a + ".route"
  assert_true(exists(route_id), "app has route config: " + a)
  assert_neq(content(route_id), "", "route has value: " + a)
}
"""
}
