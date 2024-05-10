import { analyzeMetafile, build } from "esbuild"
import { sassPlugin } from "esbuild-sass-plugin"
import vue from "esbuild-vue"
import fs from "fs"
import path from "path"

const pathEntryPoints = path.join(process.cwd(), "app/javascript")

fs.readdir(pathEntryPoints, (_, files) => {
  const entryPoints = files.reduce((acc, file) => {
    const fullPath = path.resolve(pathEntryPoints, file)
    // Any javascript file right under app/javascript becomes an entrypoint
    if (fs.lstatSync(fullPath).isDirectory()) return acc

    acc.push(fullPath)
    return acc
  }, [])

  build({
    entryPoints,
    bundle: true,
    sourcemap: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    watch: process.argv.includes("--watch"),
    loader: { ".js": "jsx", ".png": "dataurl", ".gif": "dataurl" },
    plugins: [
      vue(),
      sassPlugin({
        loadPaths: [path.resolve(process.cwd(), "node_modules")]
      })
    ],
    metafile: true,
    // splitting: true,
    format: "esm"
  })
    .then(async result => {
      const displayReport = process.argv.includes("--report");

      if (displayReport) {
        // Simple output bundling results
        const report = await analyzeMetafile(result.metafile);
        console.log(report);

        // For further results, you may want print a file and upload to https://www.bundle-buddy.com/esbuild
        // require('fs').writeFileSync('meta.json', JSON.stringify(result.metafile))
      }
    })
    .catch(() => process.exit(1));
});
