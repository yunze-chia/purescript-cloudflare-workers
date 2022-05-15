export const makeResponse = res => {
    let pairs = res.headers.map(({ value0, value1 }) => ({ [value0]: value1 }))
    return new Response(res.body != "" ? res.body : undefined, {
        status: res.status,
        headers: Object.assign({}, ...pairs),
    })
}