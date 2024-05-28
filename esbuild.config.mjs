import * as esbuild from "esbuild"
import { sassPlugin } from "esbuild-sass-plugin"
import vue from "esbuild-vue"
import alias from "esbuild-plugin-alias"
import env from "@intrnl/esbuild-plugin-env"
import fs from "fs"
import path from "path"

const pathEntryPoints = path.join(process.cwd(), "app/javascript")

fs.readdir(pathEntryPoints, async (_, files) => {
  const entryPoints = files.reduce((acc, file) => {
    const fullPath = path.resolve(pathEntryPoints, file)
    // Any javascript file right under app/javascript becomes an entrypoint
    if (fs.lstatSync(fullPath).isDirectory()) return acc

    acc.push(fullPath)
    return acc
  }, [])

  const config = {
    entryPoints,
    bundle: true,
    sourcemap: true,
    metafile: true,
    format: "esm",
    outdir: path.join(process.cwd(), "app/assets/builds"),
    preserveSymlinks: true,
    // splitting: true,
    loader: {
      ".js": "jsx",
      ".png": "dataurl",
      ".gif": "dataurl",
      ".eot": "file",
      ".woff": "file",
      ".woff2": "file",
      ".svg": "file",
      ".ttf": "file",
    },
    define: {
      global: "window",
    },
    plugins: [
      vue(),
      alias({
        // enforces Vue package to use the compiler-included build version
        // https://v2.vuejs.org/v2/guide/installation.html#Runtime-Compiler-vs-Runtime-only
        vue: path.resolve(process.cwd(), "node_modules/vue/dist/vue.esm.js"),
      }),
      env({
        // Only inject environment variables from dotenv files
        filter: (_, filename) => filename,
      }),
      sassPlugin({
        loadPaths: [path.resolve(process.cwd(), "node_modules")],
        quietDeps: true
      }),
    ]
  }

  if (process.argv.includes("--watch")) {
    // watch mode requires the context, not the build
    const ctx = await esbuild.context(config);
    await ctx.watch()

    // free resources
    process.on('SIGINT', async () => await ctx.dispose());
  } else {
    const result = await esbuild.build(config);

    if (process.argv.includes("--report")) {
      console.log(await esbuild.analyzeMetafile(result.metafile));
    }
  }
});
