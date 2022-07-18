
testorio_dir="Testorio"
if [ -d $testorio_dir ]; then
   rm -rf $testorio_dir
fi
git clone --recurse-submodules -j8 https://github.com/GlassBricks/Testorio.git $testorio_dir
cd $testorio_dir
git checkout 8189395309aa033c7915f4c783f3cbfc9c19ade3
