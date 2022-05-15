export const kvBindingImpl = just => nothing => env => name => {
    let result = env[name]
    return result ? just(result) : nothing
}

export const putImpl = left => right => kv => key => value => expiration => expirationTtl => metadata => async () => {
    if (expiration === undefined && expirationTtl === undefined && metadata === undefined) {
        return await kv.put(key, value)
            .then(v => right(v))
            .catch(err => left(err))
    }

    let options = {}
    if (expiration) {
        options.expiration = expiration
    } else if (expirationTtl) {
        options.expirationTtl = expirationTtl
    }
    if (metadata) {
        options.metadata = metadata
    }
    return await kv.put(key, value, options)
        .then(v => right(v))
        .catch(err => left(err))
}

export const getImpl = left => right => kv => key => async () => {
    return await kv.get(key)
        .then(v => right(v))
        .catch(err => left(err))
}

export const deleteImpl = left => right => kv => key => async () => {
    return await kv.delete(key)
        .then(v => right(v))
        .catch(err => left(err))
}

export const listImpl = left => right => kv => prefix => limit => cursor => async () => {
    return await kv.list({ prefix, limit, cursor })
        .then(v => right(v))
        .catch(err => left(err))
}