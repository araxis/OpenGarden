using System.Globalization;
using System.Text;

namespace OpenGarden.Designer.Models;

public sealed class DesignerState
{
    public string OutputMode { get; set; } = "Print Layout";
    public bool OpenGridSupport { get; set; }
    public int SubtractSlots { get; set; } = 0;
    public string SlotPlacement { get; set; } ="Center";
    public string RenderQuality { get; set; } = "Preview";
    public double PrintSpacing { get; set; } = 20;

    public double PotHeight { get; set; } = 100;
    public double PotWidth { get; set; } = 70;
    public double PotDepth { get; set; } = 70;
    public double ReservoirRatio { get; set; } = 0.3;

    public double SeatHeight { get; set; } = 5;
    public double WallThickness { get; set; } = 2;
    public double BaseThickness { get; set; } = 2;

    public string GridRows { get; set; } = "1*";
    public string GridColumns { get; set; } = "1*";
    public string DefaultFeature { get; set; } = FeatureTypes.Pot;
    public double GridWallThickness { get; set; } = 2;
    public List<CellFeatureConfig> CellFeatures { get; } = [new()];

    public string GridLabel => $"{TrackCount(GridRows)} x {TrackCount(GridColumns)}";

    public string PotVisualStyle =>
        $"--pot-w:{Math.Clamp(PotWidth / 110, 0.55, 1.8):0.00};--pot-d:{Math.Clamp(PotDepth / 110, 0.55, 1.8):0.00};--pot-h:{Math.Clamp(PotHeight / 160, 0.55, 1.8):0.00};";

    public string GenerateScadConfig() => string.Join(Environment.NewLine, new[]
    {
        $"Output_Mode = \"{OutputMode}\";",
        $"OpenGrid_Support = {Bool(OpenGridSupport)};",
        $"Subtracted_Slots = {SubtractSlots};",
        $"Slot_Placement = \"{SlotPlacement}\";",
        $"Print_Spacing = {Format(PrintSpacing)};",
        $"Render_Quality = \"{RenderQuality}\";",
        $"Pot_Height = {Format(PotHeight)};",
        $"Pot_Width = {Format(PotWidth)};",
        $"Pot_Depth = {Format(PotDepth)};",
        $"Reservoir_Height_Ratio = {Format(ReservoirRatio)};",
        $"Seat_Height = {Format(SeatHeight)};",
        $"Wall_Thickness = {Format(WallThickness)};",
        $"Base_Thickness = {Format(BaseThickness)};",
        $"Grid_Row_Sizes = \"{Escape(GridRows)}\";",
        $"Grid_Column_Sizes = \"{Escape(GridColumns)}\";",
        $"Cell_Default_Feature = \"{DefaultFeature}\";",
        $"Grid_Cell_Spans = \"{Escape(GenerateCellSpans())}\";",
        $"Grid_Wall_Thickness = {Format(GridWallThickness)};",
        $"Cell_Feature_Overrides = \"{Escape(GenerateFeatureOverrides())}\";"
    });

    public string GenerateCellSpans() =>
        string.Join(";", CellFeatures
            .Where(feature => feature.SpanRows > 1 || feature.SpanColumns > 1)
            .Select(feature => $"{feature.Row},{feature.Column}={feature.SpanRows}x{feature.SpanColumns}"));

    public string GenerateFeatureOverrides() =>
        string.Join("; ", CellFeatures.Select(feature => feature.ToOverrideText()));

    public static int TrackCount(string value) =>
        string.IsNullOrWhiteSpace(value) ? 1 : value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Length;

    public static string Format(double value) => value.ToString("0.###", CultureInfo.InvariantCulture);

    private static string Bool(bool value) => value ? "true" : "false";

    private static string Escape(string value) => value.Replace("\\", "\\\\").Replace("\"", "\\\"");
}

public sealed class RendererResult
{
    public bool Ok { get; set; }
    public string Message { get; set; } = "";
    public string DownloadUrl { get; set; } = "";
    public string FileName { get; set; } = "";
    public int ByteLength { get; set; }
    public double ElapsedMs { get; set; }
    // Add this to hold the actual STL data
    public byte[]? StlBytes { get; set; }
}

public sealed class CellFeatureConfig
{
    public int Row { get; set; } = 1;
    public int Column { get; set; } = 1;
    public int SpanRows { get; set; } = 1;
    public int SpanColumns { get; set; } = 1;
    public string Feature { get; set; } = FeatureTypes.DrainHoles;

    public DrainHoleFeature DrainHoles { get; set; } = new();
    public LidLipFeature LidLip { get; set; } = new();
    public WickPortFeature WickPort { get; set; } = new();
    public FillTubeFeature FillTube { get; set; } = new();

    public string ToOverrideText()
    {
        var builder = new StringBuilder($"{Row},{Column}: {FeatureTypes.ToAlias(Feature)}");

        foreach (var parameter in Parameters())
        {
            builder.Append(',').Append(parameter);
        }

        return builder.ToString();
    }

    private IEnumerable<string> Parameters() => Feature switch
    {
        FeatureTypes.DrainHoles =>
        [
            $"pattern={DrainHoles.PatternAlias}",
            $"rows={DrainHoles.Rows}",
            $"cols={DrainHoles.Columns}",
            $"diameter={DesignerState.Format(DrainHoles.Diameter)}",
            $"padding={DesignerState.Format(DrainHoles.Padding)}"
        ],
        FeatureTypes.LidLip =>
        [
            $"depth={DesignerState.Format(LidLip.Depth)}",
            $"width={DesignerState.Format(LidLip.Width)}"
        ],
        FeatureTypes.WickPort =>
        [
            $"diameter={DesignerState.Format(WickPort.Diameter)}",
            $"rim={WickPort.Rim.ToString().ToLowerInvariant()}"
        ],
        FeatureTypes.FillTube =>
        [
            $"clearance={DesignerState.Format(FillTube.Clearance)}"
        ],
        _ => []
    };
}

public sealed class DrainHoleFeature
{
    public string Pattern { get; set; } = "Rectangle";
    public string PatternAlias => Pattern == "Circle" ? "C" : "R";
    public int Rows { get; set; } = 4;
    public int Columns { get; set; } = 4;
    public double Diameter { get; set; } = 5;
    public double Padding { get; set; } = 25;
}

public sealed class LidLipFeature
{
    public double Depth { get; set; } = 2;
    public double Width { get; set; } = 8;
}

public sealed class WickPortFeature
{
    public double Diameter { get; set; } = 10;
    public bool Rim { get; set; } = true;
}

public sealed class FillTubeFeature
{
    public double Clearance { get; set; } = 0.8;
}

public static class FeatureTypes
{
    public const string Pot = "Pot";
    public const string Box = "Box";
    public const string FillTube = "FillTube";
    public const string WickPort = "WickPort";
    public const string DrainHoles = "DrainHoles";
    public const string LidLip = "LidLip";

    public static readonly string[] All = [DrainHoles, LidLip, WickPort, FillTube, Box];
    public static readonly string[] Defaults = [Pot, Box, FillTube, WickPort];

    public static string ToAlias(string feature) => feature switch
    {
        DrainHoles => "dh",
        LidLip => "ll",
        WickPort => "wp",
        FillTube => "ft",
        Box => "b",
        _ => feature
    };
}
