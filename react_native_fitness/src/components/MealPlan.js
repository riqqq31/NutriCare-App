import React from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { COLORS } from '../constants/theme';

const MealItem = ({ title, time, kCal, macros, images }) => {
  return (
    <View style={styles.mealCard}>
      <View style={styles.mealHeader}>
        <Text style={styles.mealTitle}>{title}</Text>
        <View style={styles.timeTag}>
          <MaterialIcons name="schedule" size={12} color="#6B7280" />
          <Text style={styles.timeText}>{time}</Text>
        </View>
      </View>
      
      <View style={styles.mealContent}>
        {/* Stacked Images */}
        <View style={styles.imageStack}>
          {images.map((img, index) => (
             img === 'plus' ? (
                <View key={index} style={[styles.imageWrapper, styles.plusWrapper, { zIndex: images.length - index, marginLeft: index === 0 ? 0 : -12 }]}>
                   <Text style={styles.plusText}>+</Text>
                </View>
             ) : (
                <Image 
                    key={index}
                    source={{ uri: img }}
                    style={[styles.foodImage, { zIndex: images.length - index, marginLeft: index === 0 ? 0 : -12 }]} 
                />
             )
          ))}
        </View>
        
        {/* Info */}
        <View style={styles.infoContainer}>
           <Text style={styles.caloriesText}>{kCal} <Text style={styles.unitText}>kcal</Text></Text>
           <Text style={styles.macrosText}>{macros}</Text>
        </View>
      </View>
    </View>
  );
};

const MealPlan = () => {
  return (
    <View style={styles.section}>
      <View style={styles.header}>
        <Text style={styles.title}>My Meal Plan</Text>
        <TouchableOpacity style={styles.addButton}>
          <MaterialIcons name="add" size={18} color="black" />
        </TouchableOpacity>
      </View>
      
      {/* Date Selector */}
      <View style={styles.dateSelector}>
        <View style={styles.dateLeft}>
          <MaterialIcons name="calendar-today" size={16} color="#6B7280" />
          <Text style={styles.dateText}>Sat, 09 September 2023</Text>
        </View>
        <MaterialIcons name="expand-more" size={20} color="#9CA3AF" />
      </View>

      <MealItem 
        title="Breakfast"
        time="05.00 am - 07.00 am"
        kCal="380"
        macros="250kcal • 10kcal • 120kcal"
        images={[
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDIW02qIX_7wdlcF9May8B6n7XHMYgYE71JvR6Elrptll3HKCYmh28-dm-PFREsBy789S-thi9wKUzGOsQRQE2h7NDD6BpyFm8N6VJbMIKfjMdEN426KgKgH89Uy_4Ds5X5sqaIKlfNVD2JwoO49s0FZSkhWzKOV3vNa8MwXME57NDfWG9kUYNBp1QgXqkI1trRa9-YfonWNoZbgcyOV8gbrlOtd_9xw6O50WcmsGfEv5c77WMgfuzZ465hfFIy-Ja7vLGnnmL5Mw",
            "https://lh3.googleusercontent.com/aida-public/AB6AXuCbmPl__52nDvB0CxAU3N-mmDV3vEt_zrZfNQ3lOUQkqhjGlqWkKg33WHe929sCEYrr8Fd6OhUiHWGPOUMPhdR97j7xNE4xY3jL-bipJzVmKEfdBATfqIJOztngZ0dbP-SgGmtDqdj8Wu-BQlaMWj41i_AbNPNajqwxiqiIvdUjyRfG2fl9Z05IsRLH0NKxPEMdq6GZLE-5sy8eYuseKCVAIzKqWlhhyRHBiZMskAP1TPvoaXoxAbeWmZ24vCx2bN188S2Hvibp0Q",
            "plus"
        ]}
      />
      <MealItem 
        title="Lunch"
        time="12.30 pm - 01.00 pm"
        kCal="420"
        macros="350kcal • 10kcal • 120kcal"
        images={[
            "https://lh3.googleusercontent.com/aida-public/AB6AXuD2xNTxVmuhFOqJHTlYGhp5wpXVQFIF9kLEF2UlsiTEXbHD8-UQuiA55etxl5X17sZXlbcrWjyHP51VQh7BCbYOb_eBrkHyFXsPyG-fb03EoRd7rtCZSSrAqaPojFIQ4G52KaKPyv1fwZFUe9kIY-x6xrG0GzZXNGB1enZ4wwxmQk-RryIXvh-tT2WL0R9wJuw3luTN_JAkcTZn4jVjESO21u-WbjBwCniAmzJaKkMiHI0Isd7P22toQi1vvmA6YGu-iHJ2F-A12w",
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDz0zc8Jg1LLQA5VNZ60IYYd3MUKnq_27JYlPWajqoaVw6xWTp2meYtYPCBpRsZMgL9NqCpPZBBFjavFD0bIl4LILRQb3J9vxZmOWxu_-3LrbVscPDvozJdRStAujZrdE1ZtCL8yf-T_ypFIH-lSDnH9LDckisquD-Bn12jnSoWVUoYc7qVr4hxZv4O3Vfm0OCrkD_ycA9dNWLz_YJYGOf8q1ex-IOVAVeYQ8RwFWkzTiCaCKMi0bco2-YKNSiFnpYLchYj0i4fFg",
            "plus"
        ]}
      />
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
  addButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  dateSelector: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: COLORS.surfaceLight,
    padding: 12,
    borderRadius: 12,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#F3F4F6',
  },
  dateLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  dateText: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.textLight,
  },
  mealCard: {
    backgroundColor: COLORS.surfaceLight,
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#F3F4F6',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  mealHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  mealTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: COLORS.textLight,
  },
  timeTag: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F3F4F6', // gray-100
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  timeText: {
    fontSize: 10,
    color: '#6B7280',
    marginLeft: 4,
    fontWeight: '500',
  },
  mealContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  imageStack: {
    flexDirection: 'row',
    paddingLeft: 0, 
  },
  imageWrapper: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: COLORS.surfaceLight,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#1F2937', // gray-800
  },
  foodImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: COLORS.surfaceLight,
  },
  plusWrapper: {
    
  },
  plusText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  infoContainer: {
    alignItems: 'flex-end',
  },
  caloriesText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.textLight,
  },
  unitText: {
    fontSize: 12,
    fontWeight: 'normal',
    color: '#9CA3AF',
  },
  macrosText: {
    fontSize: 9,
    color: '#9CA3AF',
  }
});

export default MealPlan;
