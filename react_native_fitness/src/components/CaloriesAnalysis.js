import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { COLORS } from '../constants/theme';

const ProgressBar = ({ label, value, color }) => {
  return (
    <View style={styles.progressItem}>
      <View style={styles.progressHeader}>
        <Text style={styles.label}>{label}</Text>
        <Text style={styles.value}>{value}%</Text>
      </View>
      <View style={styles.track}>
        <View style={[styles.bar, { width: `${value}%`, backgroundColor: color }]} />
      </View>
    </View>
  );
};

const CaloriesAnalysis = () => {
  return (
    <View style={styles.section}>
      <View style={styles.header}>
        <Text style={styles.title}>Calories Analysis</Text>
        <TouchableOpacity>
          <Text style={styles.detailText}>See Detail</Text>
        </TouchableOpacity>
      </View>
      
      <View style={styles.card}>
        <ProgressBar label="Carbo" value={43.5} color={COLORS.orange400} />
        <ProgressBar label="Fat" value={27.5} color={COLORS.red400} />
        <ProgressBar label="Protein" value={73.1} color={COLORS.blue500} />
        <ProgressBar label="Fiber" value={52.5} color={COLORS.green500} />
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
  detailText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6B7280',
  },
  card: {
    backgroundColor: COLORS.surfaceLight,
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    borderColor: '#F3F4F6',
    gap: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  progressItem: {
    
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  label: {
    fontSize: 12,
    fontWeight: '500',
    color: '#6B7280',
  },
  value: {
    fontSize: 12,
    fontWeight: 'bold',
    color: COLORS.textLight,
  },
  track: {
    height: 8,
    backgroundColor: '#E5E7EB', // gray-200
    borderRadius: 4,
  },
  bar: {
    height: 8,
    borderRadius: 4,
  }
});

export default CaloriesAnalysis;
