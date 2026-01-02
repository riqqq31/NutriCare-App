import React from 'react';
import { StyleSheet, View, ScrollView, Platform, StatusBar as RNStatusBar } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { COLORS } from './src/constants/theme';

import Header from './src/components/Header';
import BodyOverview from './src/components/BodyOverview';
import DailyTarget from './src/components/DailyTarget';
import MealPlan from './src/components/MealPlan';
import CaloriesAnalysis from './src/components/CaloriesAnalysis';
import NewActivity from './src/components/NewActivity';
import BottomNav from './src/components/BottomNav';

export default function App() {
  return (
    <View style={styles.container}>
      <StatusBar style="dark" backgroundColor={COLORS.backgroundLight} />
      
      {/* Main Content Area */}
      <View style={styles.contentContainer}>
        <Header />
        
        <ScrollView 
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.scrollContent}
        >
          <BodyOverview />
          <DailyTarget />
          <MealPlan />
          <CaloriesAnalysis />
          <NewActivity />
        </ScrollView>
      </View>

      {/* Fixed Bottom Navigation */}
      <View style={styles.bottomNavContainer}>
        <BottomNav />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.backgroundLight,
    paddingTop: Platform.OS === 'android' ? RNStatusBar.currentHeight : 0,
  },
  contentContainer: {
    flex: 1,
    position: 'relative',
  },
  scrollContent: {
    paddingBottom: 100, // Space for bottom nav
  },
  bottomNavContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
  }
});
