import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/uuid;

configurable string host = "mysql-b0bbee91-31fa-468c-a47f-53c8b53b9dbb-db3031748966-choreo.a.aivencloud.com";
configurable int port = 25957;
configurable string user_name_db = "avnadmin";
configurable string password = "AVNS_Slhr7YSYQ6Kc1dL9qAn";
configurable string database = "defaultdb";

type User record {|
    string user_email;
    string user_type;
    string user_id;
    string user_name;
|};

service / on new http:Listener(8080) {
    private final mysql:Client db;

    function init() returns error? {
        self.db = check new (host, user_name_db, password, database, port);
    }

    resource function get users() returns User[]|error {
        stream<User, sql:Error?> userStream = self.db->query(`SELECT * FROM Users`);
        return from User user in userStream select user;
    }

    resource function get users/[string id]() returns User|http:NotFound|error {
        User|sql:Error result = self.db->queryRow(`SELECT * FROM Users WHERE id = ${id}`);
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return result;
        }
    }

    resource function post users(@http:Payload User user) returns User|error {
        string uuid1 = uuid:createType1AsString();
        user.user_id = uuid1;
        _ = check self.db->execute(`
            INSERT INTO Users (id, type, email, name)
            VALUES (${user.user_id}, ${user.user_type}, ${user.user_email}, ${user.user_name});`);
        return user;
    }
}