#' @importFrom rlang .data
#' @noRd
ggauto_density <- function(var1) {
  ggplot2::ggplot(
    data = data.frame(x = var1, y = ""),
    mapping = ggplot2::aes(x = .data$x, y = .data$y)
  ) +
    ggdist::stat_slab(
      fill = khroma::colour("bright")(1)[1],
      scale = 0.9
    ) +
    ggdist::stat_dotsinterval(
      side = "bottom",
      fill = khroma::colour("bright")(1)[1], , scale = 0.7
    ) +
    auto_x_axis(var1)
}

#' @noRd
ggauto_scatter <- function(var1, var2) {
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2),
    mapping = ggplot2::aes(x = .data$x, y = .data$y)
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_point() +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off") +
    auto_y_axis(var2)
  return(g)
}

#' @noRd
ggauto_scatter_colour <- function(var1, var2, var3) {
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2, z = var3),
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y,
      colour = .data$z, shape = .data$z
    )
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_point(size = 2) +
    khroma::scale_colour_bright() +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off") +
    auto_y_axis(var2)
  return(g)
}

#' @noRd
ggauto_line <- function(var1, var2) {
  g <- ggplot2::ggplot(
    data = data.frame(x = var1, y = var2),
    mapping = ggplot2::aes(x = .data$x, y = .data$y)
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_line() +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off")
  return(g)
}

#' @noRd
ggauto_line_colour <- function(var1, var2, var3, base_size) {
  p_data <- data.frame(x = var1, y = var2, z = var3)
  last_date <- p_data |>
    dplyr::group_by(.data$z) |>
    dplyr::slice_max(.data$x)
  g <- ggplot2::ggplot(
    data = p_data,
    mapping = ggplot2::aes(
      x = .data$x, y = .data$y,
      colour = .data$z
    )
  ) +
    auto_zero_line(var2) +
    ggplot2::geom_line(show.legend = FALSE) +
    ggplot2::geom_point(
      data = last_date,
      mapping = ggplot2::aes(shape = .data$z)
    ) +
    ggrepel::geom_text_repel(
      data = last_date,
      mapping = ggplot2::aes(label = .data$z),
      show.legend = FALSE,
      fontface = "bold",
      direction = "y",
      hjust = 0,
      box.padding = 0.5,
      nudge_x = I(5),
      seed = 123,
      size = 0.8 * base_size * 0.3528
    ) +
    khroma::scale_colour_bright() +
    ggplot2::coord_cartesian(expand = FALSE, clip = "off")
  return(g)
}
