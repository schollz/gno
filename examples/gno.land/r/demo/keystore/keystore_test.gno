package keystore

import (
	"fmt"
	"testing"
)

func TestRender(t *testing.T) {
	Set("hello", "world")

	cases := []struct {
		path     string
		expected string
	}{
		{
			path:     "set:hello:world",
			expected: "ok",
		},
		{
			path:     "get:hello",
			expected: "world",
		},
		{
			path:     "not here",
			expected: "404",
		},
	}

	for _, tc := range cases {
		t.Run(tc.path, func(t *testing.T) {
			got := Render(tc.path)
			if got != tc.expected {
				t.Errorf("expected %s, got %s.", tc.expected, got)
			}
		})
	}
}
