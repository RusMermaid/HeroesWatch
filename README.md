# Heroes Watch

An ASP.NET Core website and PostgreSQL game catalog for Heroes of Might and Magic.

**Live website:** [heroeswatch.net](https://heroeswatch.net/)

## Project layout

- [`src/web`](src/web/README.md): the cross-platform C# web application and its locally served visual assets.
- [`src/db`](src/db/README.md): PostgreSQL schemas, migrations, catalog data, and validation tools.

The first live iteration provides the greeting page, HTTPS hosting, and a Rider remote-development workflow. Database-backed website features are the next development stage.

## Development

The primary checkout is on the VPS. Open `src/web/HeroesWatch.sln` through Rider Remote Development; normal Git Commit, Push, and Pull actions synchronize with this repository. Other contributors can also use local clones.

The website targets .NET 10 and builds on Linux, macOS, and Windows. The database remains PostgreSQL. Application code, styles, images, and deployment instructions live under `src/web`.
