db.createUser(
  {
    user: "iauAdmin",
    pwd: "doNotDoThisInARealSystem",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
)
