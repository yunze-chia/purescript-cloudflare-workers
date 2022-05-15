import { run } from "./output/Test.KVServer/index.js"

export default {
    async fetch(request, env, context) {
        return await run(request)(env)(context)()
    },
}