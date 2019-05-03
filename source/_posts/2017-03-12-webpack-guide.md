---
title: webpack 2 配置指南
date: 2017-03-12 17:55:05
categories: 
  - "前端"
  - "webpack"
tags: [webpack, React]
---

  ![images](/images/webpack.png)
*webpack 已经更新到2.2版本。webpack v1 官方已经不推荐使用,建议更新到webpack 2。 (2017-03-12)*

## 四大核心概念 (Four Core Concepts)
webpack 是现代JavaScript应用的模块打包工具（module bundler），具有高度可配置性。
在开始配置webpack之前，我们需要先理解它的四大核心概念，有助于我们理解webpack的工具方式。

<!--more-->

### 1. Entry
入口文件，让webpack用哪个文件作为项目的入口。
入口就是webpack打包的起点，并从起点开始寻找相关的依赖，从而知道打包什么。

webpack.config.js
```
module.exports = {
  entry: './path/to/my/entry/file.js'
};
```

### 2. Output
出口。
webpack帮你把相关的资源打包好了，你需要告诉它把处理完的文件放在哪里。

webpack.config.js
```
const path = require('path');

module.exports = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  }
};
```

### 3. Loaders
载入器（转换器）。
webpack 只能识别JavaScript，但是它能把各种文件(.css,.html,.scss,.jpg 等等)处理成模块，就是通过Loaders来实现的。
Loaders可以理解为把各种文件转换成相应的模块，提供给webpack打包使用的工具。

webpack.config.js
```
const path = require('path');

const config = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  },
  module: {
    rules: [
      {test: /\.(js|jsx)$/, use: 'babel-loader'}
    ]
  }
};

module.exports = config;
```

### 4. Plugins
插件
webpack的插件主要是一些对打包出来的内容做一些处理的工具（不限于此）。
比如：把所有的css文件抽离到一个css文件；压缩js；生成html模板等。

webpack.config.js
```
const HtmlWebpackPlugin = require('html-webpack-plugin'); //installed via npm
const webpack = require('webpack'); //to access built-in plugins
const path = require('path');

const config = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  },
  module: {
    rules: [
      {test: /\.(js|jsx)$/, use: 'babel-loader'}
    ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin(),
    new HtmlWebpackPlugin({template: './src/index.html'})
  ]
};

module.exports = config;
```

*上述例子来自官方文档，详情参考[Concepts](https://webpack.js.org/concepts/)*

## webpack 2 配置

### 建立项目
建一个文件夹，初始化package.json
```
mkdir webpack
cd webpack
npm init
```
*填入必要的内容，也可以直接回车跳过一些内容*

建立目录结构如下
- /dist
- /src
  - index.js
- package.json


### Install
项目中安装
```
npm install webpack --save-dev

// 指定安装某个版本
npm install webpack@<version> --save-dev
```
使用npm script时，npm会去寻找当前项目的modules中安装的webpack
```
"scripts": {
    "start": "webpack --config mywebpack.config.js"
}
```
这种使用方式是推荐的最佳实践方式

你也可以选择全局安装，这样webpack命令就全局都可以使用
```
npm install webpack -g
```
*全局安装要注意全局安装版本和项目安装的版本不同可能导致出错。*


### 配置入口和出口
安装webpack之后，我们在根目录创建webpack.config.js文件，这是webpack默认匹配的配置文件。
你也可以自定义的指定某一个配置文件：
```
--config mywebpack.config.js
```

webpack.config.js
```
const path = require('path');
const webpack = require('webpack');
module.exports = {
  context: path.resolve(__dirname, './src'),
  entry: {
    app: './app.js',
  },
  output: {
    path: path.resolve(__dirname, './dist'),
    filename: '[name].bundle.js',
  },
};
```
配置解释：
*  __dirname: 指的是项目的根目录(绝对路径)
* context: webpack的开始根目录(必须绝对路径)，默认为当前目录。推荐配置该属性，这样就可以让你的配置和你当前的工作目录解耦。
* output.path: 输出文件目录
* outputl.filename: 输出文件的名称 [name]对应于entry里的key，这里的key就是app

webpack的工作流程如下：
1. 从context文件夹开始
1. 查找entry对应文件
1. 找到入口文件后读取内容，每当遇到 import (ES6) 或者 require() （Node） 依赖项时, 它会解析这些代码, 并且打包到最终构建里. 接着它会不断递归搜索实际需要的依赖项, 直到它到达了“树”的底部.
1. 递归完所有依赖之后, Webpack 会将所有东西打包到 output.path 对应的目录, 并将 output.filename 的值作为最终的资源名.

### Loaders

#### Babel+ES6

##### install
使用ES6语法，配置Babel进行编译，需要使用[babel-loader](https://github.com/babel/babel-loader)

```
npm install babel-loader babel-core babel-preset-es2015 --save-dev

// 使用react还需要安装
npm install react react-dom --save
npm install babel-preset-react --save-dev
```

> babel-preset-es2015 es6语法包
> babel-preset-react react语法包

##### 配置
loader配置

```
module.exports = {
  //...
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        use: [{
          loader: 'babel-loader',
          options: {
            "presets": [
              "es2015",
              "react"
            ]
          }
        }],
        exclude: [
          path.resolve(__dirname, "node_modules")
        ]
      }
    ]
  }
}
```
test: 匹配的文件
excule: 排除node_modules目录
options: 这里配置的babel的配置信息

一般推荐，把babel的配置文件当初抽离到.babelrc文件中
```
{
  "presets": [
    "es2015",
    "react"
  ]
}

```

##### 其他
- babel-polyfill
Babel默认是只转换JS的语法的，一些重要的API如Promise、WeakMap，一些静态方法Array.from或Object.assign、实例方法Array.prototype.includes以及生成器函数都是没有转换的。这个时候我们就需要该包来进行转码。polyfill是会添加到全局作用对象中去就像原生的原型String一样。
Babel默认不转码的API非常多，详细清单可以查看babel-plugin-transform-runtime模块的[definitions.js](https://github.com/babel/babel/blob/master/packages/babel-plugin-transform-runtime/src/definitions.js)。


- 如果想使用ES7的一些特性，可以使用state-0或者其他对应的包。
```
npm install babel-preset-stage-0 --save-dev

// .babelrc
{
  "presets": {
    "stage-0"
  }
}
```
> stage预置条件是会后向兼容的，也就是说stage-0的预置条件是会包含stage-1、stage-2、stage-3等预置条件的


- 修饰器使用：Babel v6移除了修饰器的支持，如果要使用，需要安装第三方插件[transform-decorators-legacy](https://github.com/loganfsmyth/babel-plugin-transform-decorators-legacy)
```
npm install babel-plugin-transform-decorators-legacy --save-dev

// .babelrc
{
  "plugins": [
    "transform-decorators-legacy"
  ]
}
```

*详情可以查看[Babel Plugins](https://babeljs.io/docs/plugins/)


#### style

##### 配置
我们需要两种loader，css-loader 和 style-loader。
css-loader 会遍历css文件，找到所有的url(...)并且处理。
style-loader 会把所有的样式插入到你页面的一个 style tag 中

```
module.exports = {
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      }
    ]
  }
}
```

我们在css里经常会引用图片(url(../image.png))之类的，这里就css-loader是无法处理的，需要配合file-loader和url-loader来处理图片等静态资源
- file-loader: 将匹配到的文件复制到输出文件夹，并根据 output.publicPath 的设置返回文件路径。
- url-loader: 类似file-loader ,但是它可以返回一个DataUrl (base 64)如果文件小于设置的限制值limit。

```
module.exports = {
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      },
      {
        test: /\.(png|jpg|gif|svg|eot|ttf|woff|woff2)$/,
        loader: 'url-loader',
        options: {
          limit: 10000
        }
      }
    ]
  }
};
```

##### 使用CSS Modules
```
module.exports = {
  // …
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options:
              {
                modules: true
              }
          }
        ],
      },
      // …
    ],
  },
};
```

配置React，推荐使用[react-css-modules](https://github.com/gajus/react-css-modules)
```
npm install react-css-modules --save-dev
```

##### autoprefixer
有些样式不同浏览器需要加不同的前缀，如-webkit-，使用autoprefixer会自动帮我们加上这些前缀。
autoprefixer-loader已经废弃不再维护了，推荐使用[postcss-loader](https://github.com/postcss/postcss-loader)
```
npm install postcss-loader autoprefixer --save-dev

// webpack.config.js
module.exports = {
  // …
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options:
              {
                modules: true,
                importLoaders: 1
              }
          },
          'postcss-loader'
        ],
      },
      // …
    ],
  },
};
```
然后配置postcss，根目录下新建配置文件postcss.config.js
```
module.exports = {
  plugins: [
      require('autoprefixer')
  ]
}
```

##### 使用Sass
sass-loader依赖node-sass
```
npm install sass-loader node-sass  --save-dev

// webpack.config.js
module.exports = {
  // …
  module: {
    rules: [
      {
        test: /\.(sass|scss)$/,
        use: [
          "style-loader",
          "css-loader",
          "postcss-loader",
          "sass-loader",
        ]
      }
      // …
    ],
  },
};
```


### Plugins

#### ExtractTextWebpackPlugin
上面我们讲了webpack中style的处理，但是我们有些时候我们希望将样式抽取成独立的文件。这里我们使用 webpack 插件[ExtractTextWebpackPlugin](https://webpack.js.org/plugins/extract-text-webpack-plugin/)
```
npm install --save-dev extract-text-webpack-plugin
```

```
module.exports = {
  //...
  module: {
    rules: [
      {
        test: /\.scss/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            {
              loader: 'css-loader',
              options: {
                modules: true,
                importLoaders: 2,
                localIdentName: '[folder]__[local]__[hash:base64:5]',
              }
            },
            {
              loader: 'postcss-loader'
            }
            {
              loader: 'sass-loader'
            }
          ]
        })
      }
    ]
  },
  //...
  plugins: [
    new ExtractTextPlugin({
      filename: 'style.css',
      allChunks: false
    })
  ]
}
```
在 output 指定的目录中会有一个 style.css 文件. 最后, 在 HTML 文件中通过 <link> 标签正常引用.

#### 代码压缩
使用 [UglifyjsWebpackPlugin](https://webpack.js.org/plugins/uglifyjs-webpack-plugin/#components/sidebar/sidebar.jsx)
```
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  // ...
  plugins: [
    new UglifyJSPlugin({
      compress: {
        warnings: false
      }
    })
  ]
}
```

#### HTML模板
[HtmlWebpackPlugin](https://webpack.js.org/plugins/html-webpack-plugin/#components/sidebar/sidebar.jsx)
使用这个插件，我们可以自定义HTML模板，自动生成相应的HTML文件，包括自动插入webpack生成的css和js
```
npm install html-webpack-plugin --save-dev

// webpack.config.js
module.exports = {
  // ...
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Hello App',
      template: path.resolve(__dirname, 'src/templates/index.html'),
      filename: 'index.html',
      //chunks这个参数告诉插件要引用entry里面的哪几个入口
      chunks: ['app'],
      //要把script插入到标签里
      inject: 'body'
    })
  ]
}

```


### 配置webpack-dev-server
[webpack-dev-server](https://webpack.js.org/configuration/dev-server/#components/sidebar/sidebar.jsx)
开发环境下搭建开发服务器，可以在开发的时候实时更新页面，方便开发和调试。
```
npm install webpack-dev-server --save-dev

//webpack.config.js
module.exports = {
  ....
  devServer: {
    historyApiFallback: true,
    hot: true
  },
  ...
}
```

### Devtool
webpack提供了souce map来提高debug的效率
在配置文件中直接配置devtool属性，就可以开始source map
支持的的类型
![images](/images/sourcemap.png)
```
devtool: eval-source-map
```

### resolve

resolve属性可以配置extensions和alias
- extensions可以配置自动完成的文件后缀，例如：我们在写index.jsx的时候就可以简写成index
- alias 可以配置一些目录的别名，方便我们引入，也可以加快webpack打包时索引速度。

```
resolve: {
  extensions: ['.js', '.jsx'],
  alias: {
    components: path.resolve(__dirname, 'src/components')
  }
}
```

### npm script配置
```
"scripts": {
  "start": "webpack-dev-server --devtool eval-source-map --progress  --colors --hot",
  "build": "webpack -p --progress --colors"
}
```

一些命令的解释：
* –colors 输出的结果带彩色
* –progress 输出进度显示
* –watch 动态实时监测依赖文件变化并且更新
* –hot 是热插拔
* –display-error-details 错误的时候显示更多详细错误信息
* -w 动态实时监测依赖文件变化并且更新
* -d 提供sorcemap
* -p 对打包文件进行压缩


配置之后，开发环境直接执行
```
npm run start
```

打包则执行
```
npm run build
```

## 参考资料
> [webpack](https://webpack.js.org/)
> [[译]Webpack 2 快速入门](https://github.com/dwqs/blog/issues/46)
> [Babel](https://babeljs.io/)


## 配置Demo源码
[github](https://github.com/hhking/webpack-guides)
