export const extractPathImpl = just => nothing => urlString => {
    try {
        let url = new URL(urlString)
        return just(url.pathname)
    } catch (_) {
        return nothing
    }
}