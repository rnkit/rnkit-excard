/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TouchableHighlight
} from 'react-native';

import RNKitExcard from 'rnkit-excard';

RNKitExcard.config({
  DisplayLogo: false
})

console.log('------------------------------------');
console.log(RNKitExcard.sdkVersion);
console.log(RNKitExcard.kernelVersion);
console.log('------------------------------------');

class Button extends Component {
  render() {
    return (
      <TouchableHighlight
        onPress={() => this.props.onPress()}
        style={[styles.button, this.props.style]}
      >
        <Text style={styles.buttonText}>{this.props.title}</Text>
      </TouchableHighlight>
    )
  }
}

export default class App extends Component {

  constructor() {
    super();
    this.state = {
      content: {}
    }    
  }

  render() {

    let content = []
    let { entries } = Object;
    for (let key in this.state.content) {
      console.log();
      content.push(
        <View key={key} style={styles.result}>
          <Text style={styles.key}>{key}: <Text style={styles.value}>{this.state.content[key]}</Text></Text>
        </View>
      )
    }

    return (
      <View style={styles.container}>
        <Button
          style={styles.button}
          onPress={async () => {
            try {
              let res = await RNKitExcard.recoBankFromStream();
              this.setState({
                content: res
              })
            } catch (error) {
              console.log(error)
            }
          }}
          title="银行卡"
        />
        <Button
          style={styles.button}
          onPress={async () => {
            try {
              let res = await RNKitExcard.recoIDCardFromStreamWithSide(true);
              this.setState({
                content: res
              })
            } catch (error) {
              console.log(error)
            }
          }}
          title="身份证(正面)"
        />
        <Button
          style={styles.button}
          onPress={async () => {
            try {
              let res = await RNKitExcard.recoIDCardFromStreamWithSide(false);
              this.setState({
                content: res
              })
            } catch (error) {
              console.log(error)
            }
          }}
          title="身份证(反面)"
        />
        <Button
          style={styles.button}
          onPress={async () => {
            try {
              let res = await RNKitExcard.recoDRCardFromStream();
              this.setState({
                content: res
              })
            } catch (error) {
              console.log(error)
            }
          }}
          title="驾驶证"
        />
        <Button
          style={styles.button}
          onPress={async () => {
            try {
              let res = await RNKitExcard.recoVECardFromStream();
              this.setState({
                content: res
              })
            } catch (error) {
              console.log(error)
            }
          }}
          title="行驶证"
        />

        <View style={styles.content}>
          {content}
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexWrap: 'wrap',
    backgroundColor: '#F5FCFF',
  },
  button: {
    backgroundColor: 'rgb(255, 102, 1)',
    height: 40,
    padding: 10,
    margin: 5,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 14
  },
  content: {
    margin: 10,
    borderWidth: 1,
    borderColor: '#269ff7'
  },
  result: {
    paddingLeft: 15,
  },
  key: {
    color: '#fc3a30'
  },
  value: {
    color: '#b18bf3'
  }
});