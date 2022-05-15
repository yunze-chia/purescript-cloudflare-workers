import { run } from "../../output/Example.Basic.Main/index.js"

export default {
    async fetch(request, env, context) {
        return await run(request)(env)(context)()
    },
}