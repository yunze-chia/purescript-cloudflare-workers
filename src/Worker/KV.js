"use strict"

exports.kvBinding_ = just => nothing => env => name => {
    let result = env[name]
    return result ? just(result) : nothing
}

exports.put_ = left => right => kv => key => value => expiration => expirationTtl => metadata => () => {
    if (expiration === undefined && expirationTtl === undefined && metadata === undefined) {
        return kv.put(key, value)
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
    return kv.put(key, value, options)
        .then(v => right(v))
        .catch(err => left(err))
}

exports.get_ = left => right => kv => key => () => {
    return kv.get(key)
        .then(v => right(v))
        .catch(err => left(err))
}

exports.delete_ = left => right => kv => key => () => {
    return kv.delete(key)
        .then(v => right(v))
        .catch(err => left(err))
}

exports.list_ = left => right => kv => prefix => limit => cursor => () => {
    return kv.list({ prefix, limit, cursor })
        .then(v => right(v))
        .catch(err => left(err))
}