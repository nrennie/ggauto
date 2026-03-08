# Automatic ggplot plot

Automatically create an appropriate ggplot2 chart type based on the
classes of the provided variables.

## Usage

``` r
ggauto(
  var1 = NULL,
  var2 = NULL,
  var3 = NULL,
  data = NULL,
  xlab = "x",
  ylab = "y",
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 14,
  base_family = "sans"
)
```

## Arguments

- var1:

  First variable. Either vector (for example `plot_data$v1`), or quoted
  character string with a column name (for example `"v1"`) when passing
  in data.

- var2:

  Optional second variable.

- var3:

  Optional third variable.

- data:

  Optional data frame to get variables from.

- xlab:

  Label for the x-axis. Defaults to `"x"`.

- ylab:

  Label for the y-axis. Defaults to `"y"`.

- title:

  Optional plot title.

- subtitle:

  Optional plot subtitle.

- caption:

  Optional plot caption.

- base_size:

  Base font size. Defaults to `14`.

- base_family:

  Base font family. Defaults to `"sans"`.

## Value

A `ggplot2` plot object.

## Examples

``` r
ggauto(var1 = mtcars$mpg)

```
