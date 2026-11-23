# Heroes Watch website

Heroes Watch is a C# ASP.NET Core Razor Pages fan portal. News (`/`) shows all published articles. The Heroes menu opens a game-specific feed at `/heroes/1` through `/heroes/8`. The menu displays Heroes I–VII and Olden Era. The eighth entry uses the catalog code `HOMM8` and the route `/heroes/8`. Lore and About have dedicated routes at `/lore` and `/about`.

Discussion categories are listed at `/boards`. The side panels link to these boards and to community resources. Empty news and board pages show a construction notice. `/healthz` returns `Healthy`.

## Remote development in Rider

Use Rider Remote Development over SSH with the development account on the VPS. Open `/srv/heroeswatch/source/src/web/HeroesWatch.sln`. Source files and builds stay on the VPS; use Rider Commit, Push and Pull with the existing GitHub origin. GitHub Desktop and other contributors can pull the same branch normally.

Run development previews on loopback port 5081, separate from the production service on 5080. Use Rider port forwarding to preview the page.

## Local development

Open `src/web/HeroesWatch.sln` in JetBrains Rider, select the .NET 10 SDK, and run the **HeroesWatch** launch profile. The local address is `http://localhost:5081`.

The project targets ordinary `net10.0` with no operating-system suffix, runtime identifier, or native dependencies. It supports macOS, Linux, and Windows with the .NET 10 SDK. Website files use UTF-8; `.editorconfig` records that setting.

From this directory:

```sh
dotnet build HeroesWatch.sln
dotnet run --project HeroesWatch.Web.csproj --launch-profile HeroesWatch
```

## Publish

```sh
dotnet publish HeroesWatch.Web.csproj --configuration Release --no-self-contained --output bin/publish
dotnet bin/publish/HeroesWatch.Web.dll
```

`UseAppHost=false` produces portable managed output. Install the ASP.NET Core 10 runtime on the destination. Build output and Rider workspace state are ignored by Git.

The VPS-specific service and reverse proxy configuration live in `deploy/`. The website does not yet access the existing database in `../db`.

The interface textures are stored in `wwwroot/images`; their original sources and checksums are recorded in [TEXTURES.md](TEXTURES.md).
