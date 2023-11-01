# Amazon Bedrock Plugin for zsh

## Installation

### Zinit

```
zinit load Nasubikun/zsh-bedrock
```

### Antigen

```
antigen bundle Nasubikun/zsh-bedrock@main
```

### Sheldon

```
[plugins.ni]
github = "Nasubikun/zsh-bedrock"
```

### Manually

```
curl https://raw.githubusercontent.com/Nasubikun/zsh-bedrock/main/zsh-bedrock.zsh > zsh-bedrock.zsh
source zsh-bedrock.zsh
```

## Usage

```
❯ brk What does 'bedrock' mean?
 Bedrock refers to the solid rock layer underneath surface materials like soil and sediment. Some key things to know about bedrock:

- It is the hardest, most solid layer of rock in the crust of the Earth. It is usually made up of igneous, metamorphic or sedimentary rock.

- Bedrock generally cannot be excavated by hand-held tools and requires explosives or heavy machinery to remove. This makes it an ideal foundation to build on.

- The depth at which bedrock is found varies greatly by location. In some areas it may be exposed at the surface, while in others it can be hundreds of feet deep.

- Major types of bedrock include granite, basalt, sandstone, shale and limestone. The type found in an area depends on the geological forces that formed it.

- Groundwater, oil and natural gas are often found trapped in bedrock layers beneath the surface. Fractures and pores in the bedrock act as reservoirs for these resources.

- Bedrock geology provides clues about the history and formation of the land in a region. Studying it helps geologists reconstruct past geological events.

So in summary, bedrock refers to the hard, solid rock layer under the loose surface materials that serves as the foundation for buildings, bridges and other structures. Knowing the depth and type of bedrock is important for construction, resource extraction and geology.

---

❯ brk -t 日本一高い山は富士山です。
 The highest mountain in Japan is Mount Fuji.

```

## Commands and Options

- `brk`
  Use this command to interact with Bedrock.
  Followed by the prompt like this: `brk Hello, nice to meet you.`

- `brk -t`
  Use this command if you want Bedrock to do the translation for you.
  You can use like this: `brk -t What's the highest mountain in the world?`

- `brk -c`
  You can update config with this command.
  Currently,
