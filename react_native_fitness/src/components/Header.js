import React from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { COLORS } from '../constants/theme';

const Header = () => {
  return (
    <View style={styles.container}>
      {/* Profile Section */}
      <View style={styles.profileSection}>
        <View style={styles.imageContainer}>
          <Image 
            source={{ uri: "https://lh3.googleusercontent.com/aida-public/AB6AXuASPKSfTelQYnrvE4rqUMm13jOAVMAGWdmZcLr3Sju6M72Vh6F7WmdokAY6FZLpLHpNZoxojK-STpBkU2Qsk5e6PIAjQ5HyZmvmbcQjDJCpO6AVR-MMDnQFJZf1w8tP_KATNFj-gsFL05qxC20RAsCfScQtRG7NMxRl4KoTklT04PkcHH5_JPLVYqkdRrMzcOJGkk5D-9CSomB8IzH21ZAYTL0mVKPStnyZwlUpin8CgLBrR4rSUGlUYTYeyrmt6Gv-XVfwL0Pw8Q" }} 
            style={styles.profileImage}
          />
          <View style={styles.notificationDot} />
        </View>
        <View style={styles.textContainer}>
          <Text style={styles.welcomeText}>Welcome Back,</Text>
          <Text style={styles.nameText}>Jenny Wilson</Text>
        </View>
      </View>

      {/* Actions */}
      <View style={styles.actions}>
        <TouchableOpacity style={styles.iconButton}>
          <MaterialIcons name="notifications-none" size={24} color="#4B5563" />
        </TouchableOpacity>
        <TouchableOpacity style={[styles.iconButton, styles.menuButton]}>
          <MaterialIcons name="expand-more" size={24} color="black" />
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 20,
    backgroundColor: COLORS.backgroundLight,
  },
  profileSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  imageContainer: {
    position: 'relative',
  },
  profileImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: COLORS.surfaceLight,
  },
  notificationDot: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 12,
    height: 12,
    backgroundColor: '#22C55E',
    borderRadius: 6,
    borderWidth: 2,
    borderColor: COLORS.surfaceLight,
  },
  textContainer: {
    marginLeft: 12,
  },
  welcomeText: {
    fontSize: 12,
    color: '#6B7280',
  },
  nameText: {
    fontSize: 18,
    fontWeight: '700',
    color: COLORS.textLight,
  },
  actions: {
    flexDirection: 'row',
  },
  iconButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: COLORS.surfaceLight,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 12,
    // Shadow
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  menuButton: {
    backgroundColor: COLORS.primary,
  }
});

export default Header;
