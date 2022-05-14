db.createCollection('planets');
db.planets.insertMany(
  [
    {
      "name": "Mercury",
      "radius": 2439,
      "year": 88
    },
    {
      "name": "Venus",
      "radius": 6052,
      "year": 225
    },
    {
      "name": "Earth",
      "radius": 6371,
      "year": 365
    },
    {
      "name": "Mars",
      "radius": 3389,
      "year": 687
    },
    {
      "name": "Jupiter",
      "radius": 69911,
      "year": 4333
    },
    {
      "name": "Saturn",
      "radius": 58232,
      "year": 10759
    },
    {
      "name": "Uranus",
      "radius": 25362,
      "year": 30685
    },
    {
      "name": "Neptune",
      "radius": 24622,
      "year": 60188
    }
  ]
);
