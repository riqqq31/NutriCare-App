import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS } from '../constants/theme';

const CircularProgress = ({ value, label, color, rotation = '0deg', borderConfig = {} }) => {
  return (
    <View style={styles.circularContainer}>
      <View style={[
        styles.circle, 
        { 
          borderColor: '#374151', // gray-700
          borderWidth: 3 
        }
      ]}>
        <View style={[
          styles.circle, 
          { 
            position: 'absolute',
            borderWidth: 3,
            borderColor: 'transparent',
            ...borderConfig, // e.g., borderLeftColor: color
            transform: [{ rotate: rotation }]
          }
        ]} />
        <View style={{ transform: [{ rotate: '-' + rotation }] }}>
             <Text style={styles.ringValue}>{value}</Text>
        </View>
      </View>
      <Text style={styles.ringLabel}>{label}</Text>
    </View>
  );
};

const BodyOverview = () => {
  return (
    <View style={styles.section}>
      <View style={styles.header}>
        <Text style={styles.title}>Body Overview</Text>
        <View style={styles.monthlyButton}>
          <Text style={styles.monthlyText}>Monthly</Text>
          {/* Simple icon representation */}
          <Text style={{ fontSize: 12, marginLeft: 4 }}>▼</Text>
        </View>
      </View>
      
      <View style={styles.card}>
        <View style={styles.cardContent}>
          <Text style={styles.subtitle}>
            You've gained <Text style={styles.highlightText}>2kg</Text> in a month keep it up!
          </Text>
          <Text style={styles.smallLabel}>Still need to gain</Text>
          
          <View style={styles.kcalContainer}>
            <Text style={styles.kcalValue}>950</Text>
            <Text style={styles.kcalUnit}>kcal</Text>
          </View>

          <View style={styles.ringsRow}>
            <CircularProgress 
               value="35%" label="Protein" color={COLORS.primary} 
               borderConfig={{ borderLeftColor: COLORS.primary }} 
               rotation="45deg"
            />
            <CircularProgress 
               value="65%" label="Carbo" color="#FFC107" 
               borderConfig={{ borderTopColor: '#FFC107', borderRightColor: '#FFC107' }} 
               rotation="-45deg"
            />
            <CircularProgress 
               value="65%" label="Fat" color="#EF4444" 
               borderConfig={{ borderRightColor: '#EF4444' }} 
               rotation="45deg"
            />
          </View>
        </View>
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
  monthlyButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.surfaceLight,
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#F3F4F6', // gray-100
  },
  monthlyText: {
    fontSize: 12,
    fontWeight: '600',
    color: COLORS.textLight,
  },
  card: {
    backgroundColor: COLORS.accentDark,
    borderRadius: 24,
    padding: 24,
    overflow: 'hidden',
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 8,
  },
  cardContent: {
    alignItems: 'center',
  },
  subtitle: {
    color: '#9CA3AF', // gray-400
    fontSize: 14,
    marginBottom: 4,
    textAlign: 'center',
  },
  highlightText: {
    color: 'white',
    fontWeight: 'bold',
  },
  smallLabel: {
    color: '#6B7280', // gray-500
    fontSize: 12,
    marginBottom: 16,
  },
  kcalContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginBottom: 24,
  },
  kcalValue: {
    fontSize: 36,
    fontWeight: 'bold',
    color: 'white',
  },
  kcalUnit: {
    fontSize: 16,
    color: '#9CA3AF',
    marginLeft: 4,
  },
  ringsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    paddingHorizontal: 10,
  },
  circularContainer: {
    alignItems: 'center',
    gap: 8,
  },
  circle: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
  },
  ringValue: {
    color: 'white',
    fontSize: 10,
    fontWeight: 'bold',
  },
  ringLabel: {
    color: '#9CA3AF',
    fontSize: 12,
  },
});

export default BodyOverview;
