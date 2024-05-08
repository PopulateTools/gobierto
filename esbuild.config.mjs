import { build, analyzeMetafile } from "esbuild"
import path from "path"

build({
    entryPoints: ["app/javascript/main.js"],
    bundle: true,
    sourcemap: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    watch: process.argv.includes("--watch"),
    loader: { ".js": "jsx", ".png": "dataurl", ".gif": "dataurl" },
    plugins: [],
    metafile: true,
    // splitting: true,
    format: "esm"
  })
  .then(async result => {
    const displayReport = process.argv.includes("--report")

    if (displayReport) {
      // Simple output bundling results
      const report = await analyzeMetafile(result.metafile)
      console.log(report)

      // For further results, you may want print a file and upload to https://www.bundle-buddy.com/esbuild
      // require('fs').writeFileSync('meta.json', JSON.stringify(result.metafile))
    }
  })
  .catch(() => process.exit(1));
