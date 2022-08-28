
testorio_dir="Testorio"
if [ -d $testorio_dir ]; then
   rm -rf $testorio_dir
fi
git clone --recurse-submodules -j8 https://github.com/GlassBricks/Testorio.git $testorio_dir
cd $testorio_dir
echo "Make testorio at $(pwd)"
git checkout cd3cedf6b6cb7def05ff1c79c11958d4d0400c94


cat <<EOF > allmods.patch
diff --git a/src/init.ts b/src/init.ts
index 947b902..3c3778f 100644
--- a/src/init.ts
+++ b/src/init.ts
@@ -18,9 +18,7 @@ function init(
   }
   initCalled = true
   remote.add_interface("testorio-tests-available-for-" + script.mod_name, {})
-  if (script.mod_name === settings.global["testorio:test-mod"].value) {
-    require("@NoResolution:__testorio__/_testorio")(files, config)
-  }
+  require("@NoResolution:__testorio__/_testorio")(files, config)
 }
 
 export = init
EOF

 git apply allmods.patch
