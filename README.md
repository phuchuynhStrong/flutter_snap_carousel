# Snap Carousel

An Flutter Snap Carousel which provide ability to show more than one UI component inside the Carousel's viewport. Pull requests are welcome

## Features

- Use to create Carousel with ability to snap at a position after scrolling

## Getting Started

Make sure you add the lib dependency in your flutter project.

```
dependencies:
  snap_carousel: 0.1.0
```

Then you should run `flutter packages get` to update your packages in your IDE.

## Example Project

Checkout the project inside `example` folder.

## Usage

Use `createCarousel` factory function to create an Snap Carousel instance.
```
AmazingCarousel.createCarousel(
  childCount: [CAROUSEL_LENGTH],
  childWidth: [CAROUSEL_CHILD_WIDTH],
  paddingHorizontal: [CAROUSEL_PADDING_HORIZONTAL],
  paddingBetweenChildren: [PADDING_BETWEEN_ITEMS],
  onSnap: (page) {
    // Carousel has stop at page.
  },
  itemBuilder: (BuildContext context, int pos) {
    // Build your carousel child.
  },
)
```

Properties:

|Name|Usage|Type|
|---|---|---|
|`childCount`| Items count |`int`|
|`childWidth`| Single item width |`double`|
|`paddingHorizontal`| Horizontal padding of the Carousel |`double`|
|`paddingBetweenChildren`| Horizontal padding between items |`double`|
|`onSnap`| Callback when Carousel snap at a position |`ValueChanged<int>`|
|`itemBuilder`| ItemBuilder which is function receive `BuildContext` and child's position for you to build Carousel's childrens |`Function`|

## Support

Email me at `phuchuynh.strong@gmail.com` for any support needed

