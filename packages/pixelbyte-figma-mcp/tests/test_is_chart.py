"""Tests for _is_chart_or_illustration function."""
import pytest
import sys
sys.path.insert(0, '..')

from figma_mcp import _is_chart_or_illustration


class TestIsChartOrIllustration:
    """Test chart/illustration detection."""

    def test_node_with_export_settings_is_chart(self):
        """A node with exportSettings is likely a chart/illustration."""
        node = {
            'id': '6:34',
            'name': 'Bar Chart',
            'type': 'FRAME',
            'absoluteBoundingBox': {'width': 65, 'height': 98},
            'exportSettings': [{'format': 'PNG'}],
            'children': []
        }
        assert _is_chart_or_illustration(node) is True

    def test_large_frame_with_vectors_is_chart(self):
        """A frame >50px with multiple vector children is likely a chart."""
        node = {
            'id': '6:34',
            'name': 'Growth Chart',
            'type': 'FRAME',
            'absoluteBoundingBox': {'width': 200, 'height': 150},
            'children': [
                {'id': '1', 'type': 'VECTOR'},
                {'id': '2', 'type': 'VECTOR'},
                {'id': '3', 'type': 'VECTOR'},
                {'id': '4', 'type': 'RECTANGLE'},
            ]
        }
        assert _is_chart_or_illustration(node) is True

    def test_small_icon_is_not_chart(self):
        """A 32x32 icon frame is NOT a chart."""
        node = {
            'id': '3:230',
            'name': 'check-icon',
            'type': 'FRAME',
            'absoluteBoundingBox': {'width': 32, 'height': 32},
            'children': [
                {'id': '1', 'type': 'VECTOR'},
            ]
        }
        assert _is_chart_or_illustration(node) is False
