import lib from "./output/Test.KVServer/index.js"

export default {
    fetch(request, env, context) {
        return lib.run(request)(env)(context)()
    },
}