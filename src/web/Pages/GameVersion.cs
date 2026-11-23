namespace HeroesWatch.Web.Pages;

public sealed record GameVersion(int Number, string Code, string LegacySlug, string Label)
{
    public static IReadOnlyList<GameVersion> Supported { get; } =
    [
        new(1, "HOMM1", "heroes-i", "Heroes I"),
        new(2, "HOMM2", "heroes-ii", "Heroes II"),
        new(3, "HOMM3", "heroes-iii", "Heroes III"),
        new(4, "HOMM4", "heroes-iv", "Heroes IV"),
        new(5, "HOMM5", "heroes-v", "Heroes V"),
        new(6, "HOMM6", "heroes-vi", "Heroes VI"),
        new(7, "HOMM7", "heroes-vii", "Heroes VII"),
        new(8, "HOMM8", "olden-era", "Olden Era")
    ];
}
