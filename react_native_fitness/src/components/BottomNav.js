import React from 'react';
import { View, StyleSheet, TouchableOpacity, Dimensions } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { COLORS } from '../constants/theme';

const { width } = Dimensions.get('window');

const BottomNav = () => {
  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.activeBtn}>
        <MaterialIcons name="home" size={24} color="black" />
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.inactiveBtn}>
        <MaterialIcons name="bar-chart" size={24} color="#9CA3AF" />
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.inactiveBtn}>
        <MaterialIcons name="show-chart" size={24} color="#9CA3AF" />
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.inactiveBtn}>
        <MaterialIcons name="calendar-today" size={24} color="#9CA3AF" />
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.inactiveBtn}>
        <MaterialIcons name="person" size={24} color="#9CA3AF" />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingBottom: 20, // safe area padding approx
    height: 80,
    backgroundColor: COLORS.accentDark,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingHorizontal: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -5 },
    shadowOpacity: 0.1,
    shadowRadius: 15,
    elevation: 20,
    marginTop:-20 // overlap content slightly if possible, or just sit at bottom
  },
  activeBtn: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 0,
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  inactiveBtn: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
  }
});

export default BottomNav;
