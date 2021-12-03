import { StatusBar } from 'expo-status-bar';
import React from 'react';
import { StyleSheet, Text, View, Button } from 'react-native';

// Import mParticle RN SDK
import MParticle from 'react-native-mparticle'

// Import RN ATT
// https://github.com/mrousavy/react-native-tracking-transparency
import {
  getTrackingStatus,
  requestTrackingPermission
} from 'react-native-tracking-transparency';

const dictionary = {
  'not-determined': 0,
  'restricted': 1,
  'denied': 2,
  'authorized': 3
}

export default function App() {

  // GET TRACKING STATUS IF AVALIBLE
  React.useEffect(() => {
    getTrackingStatus()
      .then((status) => {
        console.log("Current ATT Status at Launch: ",status);
        MParticle.setATTStatus(dictionary[status])
      })
      .catch((e) => Alert.alert('Error', e?.toString?.() ?? e));
  }, []);

  // PROMPT ATT STATUS
  const request = React.useCallback(async () => {
    try {
      const status = await requestTrackingPermission();
      console.log("Revised ATT Status: ",status);
      switch (status) {
        case 'authorized':
          MParticle.setATTStatus(dictionary[status])
          let user = await MParticle.Identity.getCurrentUser((user)=>user.getUserIdentities((ids)=>{
            if(!Object.keys(ids).includes(MParticle.UserIdentityType.IOSAdvertiserId)){
              var request = new MParticle.IdentityRequest();
              request.setUserIdentity(
                '68c7c373-e0fa-4420-b322-81d5db5b9b24', // DEVICE IDFV
                MParticle.UserIdentityType.IOSAdvertiserId
              );
              MParticle.Identity.modify(request, (error, userId) => { error ? console.debug(error) : null})
            }
          }));
          break;
        case 'restricted':
          MParticle.setATTStatus(dictionary[status])
          break;
        case 'denied':
          MParticle.setATTStatus(dictionary[status])
          break;
        case 'authorized':
          MParticle.setATTStatus(dictionary[status])
          break;
        default:
          console.log("Something is wack with this status: ",status)
      }
    } catch (e) {
      Alert.alert('Error', e?.toString?.() ?? e);
    }
  }, []);
  request()

  return (
    <View style={styles.container}>
      <Text>Trigger Events!</Text>
      <StatusBar style="auto" />
      <Button
        onPress={()=>{
          MParticle.logEvent(
            'Button Pressed',
            MParticle.EventType.Other,
            { 'Test key': 'Test value' },
          )}}
        title='Push Me'
        accessibilityLabel='Trigger a Custom Event to mParticle'
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
