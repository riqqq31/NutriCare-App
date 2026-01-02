import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { COLORS } from '../constants/theme';

const TargetCard = ({ title, value, unit, subtitle, icon, iconColor }) => {
  return (
    <View style={styles.card}>
      <View style={styles.cardHeader}>
        <Text style={styles.cardTitle}>{title}</Text>
        <MaterialIcons name={icon} size={20} color={iconColor} />
      </View>
      <Text style={styles.cardSubtitle}>{subtitle}</Text>
      <View style={{ flexDirection: 'row', alignItems: 'baseline' }}>
        <Text style={styles.cardValue}>{value}</Text>
        <Text style={styles.cardUnit}> {unit}</Text>
      </View>
    </View>
  );
};

const DailyTarget = () => {
  return (
    <View style={styles.section}>
      <View style={styles.header}>
        <Text style={styles.title}>My Daily Target</Text>
        <TouchableOpacity>
           <Text style={styles.seeAll}>See All</Text>
        </TouchableOpacity>
      </View>
      
      <View style={styles.grid}>
        <TargetCard 
          title="Water" 
          icon="water-drop" iconColor="#3B82F6"
          subtitle="Total Cons"
          value="2300" unit="ml" 
        />
        <TargetCard 
          title="Calories" 
          icon="local-fire-department" iconColor="#F97316" // Orange
          subtitle="Total Cons"
          value="890" unit="kCal" 
        />
        <TargetCard 
          title="Weight" 
          icon="monitor-weight" iconColor="#D97706" // Amber
          subtitle="My Weight"
          value="62" unit="Kg" 
        />
        <TargetCard 
          title="BPM" 
          icon="favorite" iconColor="#EF4444" // Red
          subtitle="Heart Rate"
          value="110" unit="BPM" 
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  section: {
    marginBottom: 24,
    paddingHorizontal: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
    color: COLORS.textLight,
  },
  seeAll: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6B7280',
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  card: {
    backgroundColor: COLORS.surfaceLight,
    borderRadius: 16,
    padding: 16,
    width: '48%', // Approx 2 columns
    borderWidth: 1,
    borderColor: '#F3F4F6',
    // Shadow
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.03,
    shadowRadius: 4,
    elevation: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  cardTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: COLORS.textLight,
  },
  cardSubtitle: {
    fontSize: 10,
    color: '#9CA3AF',
    marginBottom: 4,
  },
  cardValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.textLight,
  },
  cardUnit: {
    fontSize: 12,
    color: '#9CA3AF',
  }
});

export default DailyTarget;
