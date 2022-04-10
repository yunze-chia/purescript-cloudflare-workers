import lib from "../../output/Example.Basic.Main/index.js"

export default {
    fetch(request, env, context) {
        return lib.run(request)(env)(context)()
    },
}