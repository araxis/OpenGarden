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
        $"Grid_Cell_Spans = \"{Escape(GenerateCellSpans())}\";",
        $"Grid_Wall_Thickness = {Format(GridWallThickness)};",
        $"Cell_Feature_Overrides = \"{Escape(GenerateFeatureOverrides())}\";"
    });

    public string GenerateCellSpans() =>
        string.Join(";", EffectiveCellFeatures()
            .Where(entry => entry.SpanRows > 1 || entry.SpanColumns > 1)
            .Select(entry => $"{entry.Row},{entry.Column}={entry.SpanRows}x{entry.SpanColumns}"));

    public string GenerateFeatureOverrides() =>
        string.Join("; ", EffectiveCellFeatures().Select(entry => entry.OverrideText));

    private IEnumerable<EffectiveCellFeature> EffectiveCellFeatures()
    {
        var rowCount = TrackCount(GridRows);
        var columnCount = TrackCount(GridColumns);

        // Spans must be non-overlapping for the OpenSCAD grid helpers. We enforce this by
        // resolving overlaps by order: later entries override earlier entries.
        var effective = new List<EffectiveCellFeature>();

        foreach (var feature in CellFeatures)
        {
            var row = Math.Clamp(feature.Row, 1, rowCount);
            var col = Math.Clamp(feature.Column, 1, columnCount);

            var maxRowSpan = Math.Max(1, rowCount - row + 1);
            var maxColSpan = Math.Max(1, columnCount - col + 1);
            var spanRows = Math.Clamp(feature.SpanRows, 1, maxRowSpan);
            var spanCols = Math.Clamp(feature.SpanColumns, 1, maxColSpan);

            // Remove any earlier entries that overlap this region; this makes "later wins"
            // behavior match the UI ordering and avoids emitting invalid overlapping spans.
            effective.RemoveAll(existing => RegionsOverlap(
                existing.Row, existing.Column, existing.SpanRows, existing.SpanColumns,
                row, col, spanRows, spanCols
            ));

            effective.Add(new EffectiveCellFeature(
                row,
                col,
                spanRows,
                spanCols,
                feature.ToOverrideText(row, col)
            ));
        }

        return effective;
    }

    private readonly record struct EffectiveCellFeature(
        int Row,
        int Column,
        int SpanRows,
        int SpanColumns,
        string OverrideText
    );

    private static bool RegionsOverlap(
        int rowA, int colA, int rowsA, int colsA,
        int rowB, int colB, int rowsB, int colsB
    )
    {
        var aRow0 = rowA;
        var aRow1 = rowA + rowsA - 1;
        var aCol0 = colA;
        var aCol1 = colA + colsA - 1;

        var bRow0 = rowB;
        var bRow1 = rowB + rowsB - 1;
        var bCol0 = colB;
        var bCol1 = colB + colsB - 1;

        var rowsOverlap = aRow0 <= bRow1 && bRow0 <= aRow1;
        var colsOverlap = aCol0 <= bCol1 && bCol0 <= aCol1;
        return rowsOverlap && colsOverlap;
    }

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

    public string ToOverrideText() => ToOverrideText(Row, Column);

    public string ToOverrideText(int row, int column)
    {
        var builder = new StringBuilder($"{row},{column}: {FeatureTypes.ToAlias(Feature)}");

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
