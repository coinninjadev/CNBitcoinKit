# CNBitcoinKit

Dynamic umbrella framework to be consumed by an iOS app for implementing functionality with respect to Bitcion and connecting to the Bitcoin network. The framework is an umbrella framework, which includes various static libraries such as:

* [Libbitcoin](https://github.com/libbitcoin/libbitcoin)
* [Libbitcoin-protocol](https://github.com/libbitcoin/libbitcoin-protocol)
* [Libbitcoin-client](https://github.com/libbitcoin/libbitcoin-client)
* [libsecp256k1](https://github.com/libbitcoin/secp256k1)
* [boost](https://sourceforge.net/projects/boost/files/boost/1.63.0/boost_1_63_0.tar.bz2)
* [libzmq](https://github.com/zeromq/libzmq)
* [libsodium](https://github.com/jedisct1/libsodium)

The Xcode project defines the necessary steps to build the framework as a build target.

## Getting Started

1. Clone the project
2. Type `bundle install` in a Terminal window, at the project root
3. Type `bundle exec fastlane test`
_...or..._
3. Open Xcode
4. Ensure the `CNBitcoinKit` target is selected, and build (Cmd + B). The build process will build the `libbitcoin` dependent target, which calls `make` recipes to build libbitcoin and subsequent dependencies.

### Prerequisites

What things you need to install the software and how to install them
* Xcode >= 9.2
* macOS >= 10.13

### Installing

#### Carthage (Recommended)

Recommended consumption is via Carthage. Create a `Cartfile` in the project root of your app project and add the following line:

```
github "coinninjadev/CNBitcoinKit.git" "master"
```

Then, from the command line (add the `--platform iOS` parameter if compiling only for iOS):

```
carthage bootstrap [--platform iOS]
```

Then, follow the steps for [adding a Carthage dependency to Xcode](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

## Running the tests

Open Xcode and press Cmd-U to run all tests.

## Usage

To create (and eventually broadcast) a transaction use `- (void)broadcastWithTransactionData:(CNBTransactionData *)data wallet:(CNBHDWallet *)wallet success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure` function exposed on the `CNBTransactionBuilder` class. 
In order to call that method, you'll need an instance of `CNBHDWallet` initialized with recovery words with funds available to spend, and a populated `CNBTransactionData` object, holding the data about the transaction which should be broadcasted.

#### NOTE: The above function is the _only_ function that should be used. Do not use any functions exposed by the wallet. They are exposed to allow the builder to successfully build a transaction.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for our contribution policy.  

Please read [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) for details on our code of conduct.  

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **BJ Miller** - *Initial work* - [Coin Ninja](https://coinninja.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Make recipe structure inspired by [AirBitz](https://github.com/Airbitz/airbitz-core)

