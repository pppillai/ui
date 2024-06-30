// IMPORTS ---------------------------------------------------------------------

import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam_community/colour.{type Colour}
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme/colours.{type ColourScale}

// TYPES -----------------------------------------------------------------------

///
///
pub opaque type Theme {
  Theme(
    id: String,
    dark: Bool,
    font: Fonts,
    radius: Sizes,
    space: Sizes,
    base: ColourScale,
    primary: ColourScale,
    secondary: ColourScale,
    success: ColourScale,
    warning: ColourScale,
    danger: ColourScale,
  )
}

///
///
pub type Fonts {
  Fonts(heading: String, body: String, code: String)
}

///
///
pub type Sizes {
  Sizes(
    xs: Float,
    sm: Float,
    md: Float,
    lg: Float,
    xl: Float,
    xl_2: Float,
    xl_3: Float,
  )
}

// CONSTANTS -------------------------------------------------------------------

const sans = "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\""

const code = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace"

const prefix = "w"

// CONSTRUCTORS ----------------------------------------------------------------

///
///
pub fn light_theme() -> Theme {
  let id = "lustre-ui-light"
  let font = Fonts(heading: sans, body: sans, code: code)
  let radius = Sizes(0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5)
  let space = Sizes(0.25, 0.5, 0.75, 1.0, 1.5, 2.5, 4.0)

  Theme(
    id: id,
    font: font,
    radius: radius,
    space: space,
    dark: False,
    base: colours.slate(),
    primary: colours.pink(),
    secondary: colours.cyan(),
    success: colours.green(),
    warning: colours.yellow(),
    danger: colours.red(),
  )
}

///
///
pub fn dark_theme() -> Theme {
  let id = "lustre-ui-dark"
  let font = Fonts(heading: sans, body: sans, code: code)
  let radius = Sizes(0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5)
  let space = Sizes(0.25, 0.5, 0.75, 1.0, 1.5, 2.5, 4.0)

  Theme(
    id: id,
    font: font,
    radius: radius,
    space: space,
    dark: True,
    base: colours.slate_dark(),
    primary: colours.pink_dark(),
    secondary: colours.cyan_dark(),
    success: colours.green_dark(),
    warning: colours.yellow_dark(),
    danger: colours.red_dark(),
  )
}

// MANIPULATIONS ---------------------------------------------------------------

///
///
pub fn with_heading_font(theme: Theme, font: String) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, heading: font))
}

///
///
pub fn with_body_font(theme: Theme, font: String) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, body: font))
}

///
///
pub fn with_code_font(theme: Theme, font: String) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, code: font))
}

///
///
pub fn with_radius(theme: Theme, scale: Sizes) -> Theme {
  Theme(..theme, radius: scale)
}

///
///
pub fn with_space(theme: Theme, scale: Sizes) -> Theme {
  Theme(..theme, space: scale)
}

///
///
pub fn with_base_colours(theme: Theme, colour_scale: ColourScale) -> Theme {
  Theme(..theme, base: colour_scale)
}

///
///
pub fn with_primary_colours(theme: Theme, colour_scale: ColourScale) -> Theme {
  Theme(..theme, primary: colour_scale)
}

///
///
pub fn with_secondary_colours(theme: Theme, colour_scale: ColourScale) -> Theme {
  Theme(..theme, secondary: colour_scale)
}

///
///
pub fn with_success_colours(theme: Theme, colour_scale: ColourScale) -> Theme {
  Theme(..theme, success: colour_scale)
}

///
///
pub fn with_warning_colours(theme: Theme, colour_scale: ColourScale) -> Theme {
  Theme(..theme, warning: colour_scale)
}

///
///
pub fn with_danger_colours(theme: Theme, colour_scale: ColourScale) -> Theme {
  Theme(..theme, danger: colour_scale)
}

// CONVERSIONS -----------------------------------------------------------------

///
///
pub fn to_stylesheet(theme: Theme) -> String {
  theme
  |> to_css_variables
  |> list.fold("", fn(acc, kv) { kv.0 <> ":" <> kv.1 <> ";" <> acc })
}

///
///
pub fn theme_styles(
  theme theme: Theme,
  class class: Option(String),
  dark_theme dark_theme: Option(Theme),
  dark_theme_class dark_theme_class: Option(String),
) -> Element(msg) {
  case class, dark_theme {
    Some(light_class), Some(some_dark_theme) -> {
      let light_styles =
        "." <> light_class <> " { " <> to_stylesheet(theme) <> "}"

      let dark_styles = case dark_theme_class {
        None ->
          "@media (prefers-color-scheme: dark) { "
          <> "."
          <> light_class
          <> " { "
          <> to_stylesheet(some_dark_theme)
          <> "} }"

        Some(some_dark_theme_class) ->
          "."
          <> some_dark_theme_class
          <> " "
          <> "."
          <> light_class
          <> ","
          <> "."
          <> light_class
          <> "."
          <> some_dark_theme_class
          <> " { "
          <> to_stylesheet(some_dark_theme)
          <> "}"
      }

      style_tag(theme, light_styles <> " " <> dark_styles)
    }

    None, Some(some_dark_theme) -> {
      let light_styles = "body { " <> to_stylesheet(theme) <> "}"

      let dark_styles = case dark_theme_class {
        None ->
          "@media (prefers-color-scheme: dark) { "
          <> "body { "
          <> to_stylesheet(some_dark_theme)
          <> "} }"

        Some(dark_theme_class) ->
          "body."
          <> dark_theme_class
          <> ", body ."
          <> dark_theme_class
          <> " { "
          <> to_stylesheet(some_dark_theme)
          <> "}"
      }
      style_tag(theme, light_styles <> " " <> dark_styles)
    }

    Some(light_class), None -> {
      style_tag(
        theme,
        "." <> light_class <> " { " <> to_stylesheet(theme) <> "}",
      )
    }

    None, None -> {
      style_tag(theme, "body { " <> to_stylesheet(theme) <> "}")
    }
  }
}

///
///
pub fn global_theme_styles(theme: Theme) -> Element(msg) {
  theme_styles(theme, None, None, None)
}

///
///
pub fn class_theme_styles(theme: Theme, class: String) -> Element(msg) {
  theme_styles(theme, Some(class), None, None)
}

fn style_tag(theme: Theme, content: String) {
  html.style(
    [
      attribute("data-lustre-ui-theme", case theme.id {
        "" -> "unknown"
        _ -> theme.id
      }),
    ],
    content,
  )
}

fn to_css_variables(theme: Theme) -> List(#(String, String)) {
  list.concat([
    [
      #("color-scheme", case theme.dark {
        True -> "dark"
        False -> "light"
      }),
      #(var("id"), theme.id),
      #(var("font-heading"), theme.font.heading),
      #(var("font-body"), theme.font.body),
      #(var("font-code"), theme.font.code),
      #(var("radius-xs"), float.to_string(theme.radius.xs) <> "rem"),
      #(var("radius-sm"), float.to_string(theme.radius.sm) <> "rem"),
      #(var("radius-md"), float.to_string(theme.radius.md) <> "rem"),
      #(var("radius-lg"), float.to_string(theme.radius.lg) <> "rem"),
      #(var("radius-xl"), float.to_string(theme.radius.xl) <> "rem"),
      #(var("radius-xl-2"), float.to_string(theme.radius.xl_2) <> "rem"),
      #(var("radius-xl-3"), float.to_string(theme.radius.xl_3) <> "rem"),
      #(var("spacing-xs"), float.to_string(theme.space.xs) <> "rem"),
      #(var("spacing-sm"), float.to_string(theme.space.sm) <> "rem"),
      #(var("spacing-md"), float.to_string(theme.space.md) <> "rem"),
      #(var("spacing-lg"), float.to_string(theme.space.lg) <> "rem"),
      #(var("spacing-xl"), float.to_string(theme.space.xl) <> "rem"),
      #(var("spacing-xl-2"), float.to_string(theme.space.xl_2) <> "rem"),
      #(var("spacing-xl-3"), float.to_string(theme.space.xl_3) <> "rem"),
    ],
    to_colours_variables(theme.base, "base"),
    to_colours_variables(theme.primary, "primary"),
    to_colours_variables(theme.secondary, "secondary"),
    to_colours_variables(theme.success, "success"),
    to_colours_variables(theme.warning, "warning"),
    to_colours_variables(theme.danger, "danger"),
  ])
}

fn to_colours_variables(
  colour_scale: ColourScale,
  name: String,
) -> List(#(String, String)) {
  [
    #(var(name <> "-bg"), to_rgb_segments(colour_scale.bg)),
    #(var(name <> "-bg-subtle"), to_rgb_segments(colour_scale.bg_subtle)),
    #(var(name <> "-tint"), to_rgb_segments(colour_scale.tint)),
    #(var(name <> "-tint-subtle"), to_rgb_segments(colour_scale.tint_subtle)),
    #(var(name <> "-tint-strong"), to_rgb_segments(colour_scale.tint_strong)),
    #(var(name <> "-accent"), to_rgb_segments(colour_scale.accent)),
    #(
      var(name <> "-accent-subtle"),
      to_rgb_segments(colour_scale.accent_subtle),
    ),
    #(
      var(name <> "-accent-strong"),
      to_rgb_segments(colour_scale.accent_strong),
    ),
    #(var(name <> "-solid"), to_rgb_segments(colour_scale.solid)),
    #(var(name <> "-solid-subtle"), to_rgb_segments(colour_scale.solid_subtle)),
    #(var(name <> "-solid-strong"), to_rgb_segments(colour_scale.solid_strong)),
    #(var(name <> "-solid-text"), to_rgb_segments(colour_scale.solid_text)),
    #(var(name <> "-text"), to_rgb_segments(colour_scale.text)),
    #(var(name <> "-text-subtle"), to_rgb_segments(colour_scale.text_subtle)),
  ]
}

fn to_rgb_segments(colour: Colour) -> String {
  let #(r, g, b, _) = colour.to_rgba(colour)
  let r = float.round(r *. 255.0) |> int.to_string
  let g = float.round(g *. 255.0) |> int.to_string
  let b = float.round(b *. 255.0) |> int.to_string

  r <> " " <> g <> " " <> b
}

fn var(name: String) -> String {
  "--" <> prefix <> "-" <> name
}

// THEME TOKENS ---------------------------------------------------------------

///
///
pub type FontVariables {
  FontVariables(heading: String, body: String, code: String)
}

///
///
pub type SizeVariables {
  SizeVariables(
    xs: String,
    sm: String,
    md: String,
    lg: String,
    xl: String,
    xl_2: String,
    xl_3: String,
  )
}

///
///
pub type ColourScaleVariables {
  ColourScaleVariables(
    bg: String,
    bg_subtle: String,
    //
    tint: String,
    tint_subtle: String,
    tint_strong: String,
    //
    accent: String,
    accent_subtle: String,
    accent_strong: String,
    //
    solid: String,
    solid_subtle: String,
    solid_strong: String,
    solid_text: String,
    //
    text: String,
    text_subtle: String,
  )
}

///
///
pub const font = FontVariables(
  heading: "var(--w-font-heading)",
  body: "var(--w-body-heading)",
  code: "var(--w-code-heading)",
)

///
///
pub const spacing = SizeVariables(
  xs: "var(--w-spacing-xs)",
  sm: "var(--w-spacing-sm)",
  md: "var(--w-spacing-md)",
  lg: "var(--w-spacing-lg)",
  xl: "var(--w-spacing-xl)",
  xl_2: "var(--w-spacing-xl_2)",
  xl_3: "var(--w-spacing-xl_3)",
)

pub const radius = SizeVariables(
  xs: "var(--w-radius-xs)",
  sm: "var(--w-radius-sm)",
  md: "var(--w-radius-md)",
  lg: "var(--w-radius-lg)",
  xl: "var(--w-radius-xl)",
  xl_2: "var(--w-radius-xl_2)",
  xl_3: "var(--w-radius-xl_3)",
)

pub const base = ColourScaleVariables(
  bg: "rgb(var(--w-base-bg))",
  bg_subtle: "rgb(var(--w-base-bg-subtle))",
  tint: "rgb(var(--w-base-tint))",
  tint_subtle: "rgb(var(--w-base-tint-subtle))",
  tint_strong: "rgb(var(--w-base-tint-strong))",
  accent: "rgb(var(--w-base-accent))",
  accent_subtle: "rgb(var(--w-base-accent-subtle))",
  accent_strong: "rgb(var(--w-base-accent-strong))",
  solid: "rgb(var(--w-base-solid))",
  solid_subtle: "rgb(var(--w-base-solid-subtle))",
  solid_strong: "rgb(var(--w-base-solid-strong))",
  solid_text: "rgb(var(--w-base-solid-text))",
  text: "rgb(var(--w-base-text))",
  text_subtle: "rgb(var(--w-base-text_subtle))",
)

pub const primary = ColourScaleVariables(
  bg: "rgb(var(--w-primary-bg))",
  bg_subtle: "rgb(var(--w-primary-bg-subtle))",
  tint: "rgb(var(--w-primary-tint))",
  tint_subtle: "rgb(var(--w-primary-tint-subtle))",
  tint_strong: "rgb(var(--w-primary-tint-strong))",
  accent: "rgb(var(--w-primary-accent))",
  accent_subtle: "rgb(var(--w-primary-accent-subtle))",
  accent_strong: "rgb(var(--w-primary-accent-strong))",
  solid: "rgb(var(--w-primary-solid))",
  solid_subtle: "rgb(var(--w-primary-solid-subtle))",
  solid_strong: "rgb(var(--w-primary-solid-strong))",
  solid_text: "rgb(var(--w-primary-solid-text))",
  text: "rgb(var(--w-primary-text))",
  text_subtle: "rgb(var(--w-primary-text_subtle))",
)

pub const secondary = ColourScaleVariables(
  bg: "rgb(var(--w-secondary-bg))",
  bg_subtle: "rgb(var(--w-secondary-bg-subtle))",
  tint: "rgb(var(--w-secondary-tint))",
  tint_subtle: "rgb(var(--w-secondary-tint-subtle))",
  tint_strong: "rgb(var(--w-secondary-tint-strong))",
  accent: "rgb(var(--w-secondary-accent))",
  accent_subtle: "rgb(var(--w-secondary-accent-subtle))",
  accent_strong: "rgb(var(--w-secondary-accent-strong))",
  solid: "rgb(var(--w-secondary-solid))",
  solid_subtle: "rgb(var(--w-secondary-solid-subtle))",
  solid_strong: "rgb(var(--w-secondary-solid-strong))",
  solid_text: "rgb(var(--w-secondary-solid-text))",
  text: "rgb(var(--w-secondary-text))",
  text_subtle: "rgb(var(--w-secondary-text_subtle))",
)

pub const success = ColourScaleVariables(
  bg: "rgb(var(--w-success-bg))",
  bg_subtle: "rgb(var(--w-success-bg-subtle))",
  tint: "rgb(var(--w-success-tint))",
  tint_subtle: "rgb(var(--w-success-tint-subtle))",
  tint_strong: "rgb(var(--w-success-tint-strong))",
  accent: "rgb(var(--w-success-accent))",
  accent_subtle: "rgb(var(--w-success-accent-subtle))",
  accent_strong: "rgb(var(--w-success-accent-strong))",
  solid: "rgb(var(--w-success-solid))",
  solid_subtle: "rgb(var(--w-success-solid-subtle))",
  solid_strong: "rgb(var(--w-success-solid-strong))",
  solid_text: "rgb(var(--w-success-solid-text))",
  text: "rgb(var(--w-success-text))",
  text_subtle: "rgb(var(--w-success-text_subtle))",
)

pub const warning = ColourScaleVariables(
  bg: "rgb(var(--w-warning-bg))",
  bg_subtle: "rgb(var(--w-warning-bg-subtle))",
  tint: "rgb(var(--w-warning-tint))",
  tint_subtle: "rgb(var(--w-warning-tint-subtle))",
  tint_strong: "rgb(var(--w-warning-tint-strong))",
  accent: "rgb(var(--w-warning-accent))",
  accent_subtle: "rgb(var(--w-warning-accent-subtle))",
  accent_strong: "rgb(var(--w-warning-accent-strong))",
  solid: "rgb(var(--w-warning-solid))",
  solid_subtle: "rgb(var(--w-warning-solid-subtle))",
  solid_strong: "rgb(var(--w-warning-solid-strong))",
  solid_text: "rgb(var(--w-warning-solid-text))",
  text: "rgb(var(--w-warning-text))",
  text_subtle: "rgb(var(--w-warning-text_subtle))",
)

pub const danger = ColourScaleVariables(
  bg: "rgb(var(--w-danger-bg))",
  bg_subtle: "rgb(var(--w-danger-bg-subtle))",
  tint: "rgb(var(--w-danger-tint))",
  tint_subtle: "rgb(var(--w-danger-tint-subtle))",
  tint_strong: "rgb(var(--w-danger-tint-strong))",
  accent: "rgb(var(--w-danger-accent))",
  accent_subtle: "rgb(var(--w-danger-accent-subtle))",
  accent_strong: "rgb(var(--w-danger-accent-strong))",
  solid: "rgb(var(--w-danger-solid))",
  solid_subtle: "rgb(var(--w-danger-solid-subtle))",
  solid_strong: "rgb(var(--w-danger-solid-strong))",
  solid_text: "rgb(var(--w-danger-solid-text))",
  text: "rgb(var(--w-danger-text))",
  text_subtle: "rgb(var(--w-danger-text_subtle))",
)

// BASE STYLES ----------------------------------------------------------------

pub fn base_styles() {
  html.style(
    [],
    "body { background:"
      <> css_color_value("base-bg")
      <> ";color:"
      <> css_color_value("base-text")
      <> ";font-family:"
      <> css_var_value("font-text")
      <> ";}"
      <> "h1, h2, h3, h4, h5, h6 {"
      <> css_var_value("font-heading")
      <> ";}"
      <> "code {"
      <> css_var_value("font-code")
      <> ";}",
  )
}

pub fn base_classes() {
  html.style(
    [],
    ["base", "primary", "secondary", "success", "warning", "danger"]
      |> list.map(fn(variant) {
        // .w-variant
        ".w-"
        <> variant
        <> " {"
        <> "background-color:"
        <> css_color_value(variant <> "-tint")
        <> ";border-color:"
        <> css_color_value(variant <> "-accent")
        <> ";color:"
        <> css_color_value(variant <> "-text")
        <> ";}"
        // .w-variant (anchors and buttons) - hover
        <> ".w-"
        <> variant
        <> ":is(a,button):hover {"
        <> "background-color:"
        <> css_color_value(variant <> "-tint-strong")
        <> ";border-color:"
        <> css_color_value(variant <> "-accent-strong")
        <> ";}"
        // .w-variant (anchors and buttons) - active / focus
        <> ".w-"
        <> variant
        <> ":is(a,button):is(:active:focus) {"
        <> "background-color:"
        <> css_color_value(variant <> "-tint-subtle")
        <> ";border-color:"
        <> css_color_value(variant <> "-accent-subtle")
        <> ";}"
        // .w-variant.w-solid
        <> " .w-"
        <> variant
        <> ".w-solid {"
        <> "background-color:"
        <> css_color_value(variant <> "-solid")
        <> ";color:"
        <> css_color_value(variant <> "-solid-text")
        <> ";}"
        // .w-variant.w-solid (anchors and buttons) - hover
        <> ".w-"
        <> variant
        <> ".w-solid:is(a,button):hover {"
        <> "background-color:"
        <> css_color_value(variant <> "-solid-strong")
        <> ";}"
        // .w-variant.w-solid (anchors and buttons) - active / focus
        <> ".w-"
        <> variant
        <> ".w-solid:is(a,button):is(:active:focus) {"
        <> "background-color:"
        <> css_color_value(variant <> "-solid-subtle")
        <> ";}"
      })
      |> string.join(""),
  )
}

fn css_var(id: String) -> String {
  "--" <> prefix <> "-" <> id
}

fn css_var_value(id: String) -> String {
  "var(" <> css_var(id) <> ")"
}

fn css_color_value(id) {
  "rgb(" <> css_var_value(id) <> ")"
}

// CSS RESET ------------------------------------------------------------------

///
///
pub fn css_reset() {
  html.style(
    [],
    "a,hr{color:inherit}progress,sub,sup{vertical-align:baseline}blockquote,body,dd,dl,fieldset,figure,h1,h2,h3,h4,h5,h6,hr,menu,ol,p,pre,ul{margin:0}dialog,fieldset,legend,menu,ol,ul{padding:0}*,::after,::before{box-sizing:border-box;border:0 solid currentColor}html{line-height:1.5;-webkit-text-size-adjust:100%;-moz-tab-size:4;tab-size:4;font-family:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,\"Helvetica Neue\",Arial,\"Noto Sans\",sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\",\"Segoe UI Symbol\",\"Noto Color Emoji\";font-feature-settings:normal;font-variation-settings:normal}body{line-height:inherit}hr{height:0;border-top-width:1px}abbr:where([title]){text-decoration:underline dotted}h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}a{text-decoration:inherit}b,strong{font-weight:bolder}code,kbd,pre,samp{font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,\"Liberation Mono\",\"Courier New\",monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative}sub{bottom:-.25em}sup{top:-.5em}table{text-indent:0;border-color:inherit;border-collapse:collapse}button,input,optgroup,select,textarea{font-family:inherit;font-feature-settings:inherit;font-variation-settings:inherit;font-size:100%;font-weight:inherit;line-height:inherit;color:inherit;margin:0;padding:0}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button;background-color:transparent;background-image:none}:-moz-focusring{outline:auto}:-moz-ui-invalid{box-shadow:none}::-webkit-inner-spin-button,::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}menu,ol,ul{list-style:none}textarea{resize:vertical}input::placeholder,textarea::placeholder{opacity:1;color:#9ca3af}[role=button],button{cursor:pointer}:disabled{cursor:default}audio,canvas,embed,iframe,img,object,svg,video{display:block;vertical-align:middle}img,video{max-width:100%;height:auto}[hidden]{display:none}",
  )
}
