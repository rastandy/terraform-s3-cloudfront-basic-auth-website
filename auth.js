const username = "${username}"; //process.env.username;
const password = "${password}";  //process.env.password;

const unauthResp = {
    status: "401",
    statusDescription: "Unauthorized",
    headers: {
        "www-authenticate": [
            {
                key: "WWW-Authenticate",
                value: 'Basic realm="Login"'
            }
        ]
    }
};

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;

    const authorization = headers["authorization"];
    // no Authorization header
    if (!authorization || authorization.length === 0) {
        return callback(null, unauthResp);
    }

    const credentials = authorization[0]["value"];
    const split = credentials.split(" ");

    if (split.length === 2 && split[0].toLowerCase() === "basic") {
        let decoded = new Buffer(split[1], "base64").toString("ascii");

        if (decoded === username + ":" + password) {
            return callback(null, request);
        }
    }

    return callback(null, unauthResp);
};
