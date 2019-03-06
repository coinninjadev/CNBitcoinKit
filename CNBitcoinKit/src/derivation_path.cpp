//
//  derivation_path.cpp
//  CNBitcoinKit
//
//  Created by Dan Sexton on 5/17/18.
//  Copyright © 2018 Coin Ninja, LLC. All rights reserved.
//

#include "derivation_path.hpp"

derivation_path::derivation_path(int purpose) {
    this->purpose = purpose;
}

derivation_path::derivation_path(int purpose, int coin, int account, int change, int index) {
    this->purpose = purpose;
    this->coin = coin;
    this->account = account;
    this->change = change;
    this->index = index;
}

bool derivation_path::hasPurpose() {
    return purpose >= 0;
}

bool derivation_path::hasCoin() {
    return coin >= 0;
}

bool derivation_path::hasAccount() {
    return account >= 0;
}

bool derivation_path::hasChange() {
    return change >= 0;
}

bool derivation_path::hasindex() {
    return index >= 0;
}

int derivation_path::getPurpose() {
    return purpose;
}

int derivation_path::getCoin() {
    return coin;
}

int derivation_path::getAccount() {
    return account;
}

int derivation_path::getChange() {
    return change;
}

int derivation_path::getIndex() {
    return index;
}

int derivation_path::getHardenedPurpose() {
    return purpose + hardenedOffset;
}

int derivation_path::getHardenedCoin() {
    return coin + hardenedOffset;
}

int derivation_path::getHardenedAccount() {
    return account + hardenedOffset;
}
