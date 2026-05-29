import SwiftUI

struct MasonryLayout: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 15

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? UIScreen.main.bounds.width
        let layout = calculateLayout(width: width, subviews: subviews)
        return CGSize(width: width, height: layout.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Usar bounds.width asegura que estemos usando el ancho real disponible tras paddings
        let layouts = calculateLayout(width: bounds.width, subviews: subviews)
        let columnWidth = max(0, (bounds.width - spacing * CGFloat(columns - 1)) / CGFloat(columns))
        
        for (index, subview) in subviews.enumerated() {
            let position = layouts.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(width: columnWidth, height: nil)
            )
        }
    }

    private func calculateLayout(width: CGFloat, subviews: Subviews) -> (height: CGFloat, positions: [CGPoint]) {
        // Aseguramos que el ancho no sea negativo
        let availableWidth = max(0, width)
        let columnWidth = max(0, (availableWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns))
        var columnHeights = Array(repeating: CGFloat(0), count: columns)
        var positions: [CGPoint] = []

        for subview in subviews {
            let shortestColumn = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            
            let x = CGFloat(shortestColumn) * (columnWidth + spacing)
            let y = columnHeights[shortestColumn]
            
            positions.append(CGPoint(x: x, y: y))
            
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            columnHeights[shortestColumn] += size.height + spacing
        }

        let maxHeight = columnHeights.max() ?? 0
        return (max(0, maxHeight - (maxHeight > 0 ? spacing : 0)), positions)
    }
}
