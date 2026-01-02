import React from 'react';
import { View, Text, StyleSheet, ScrollView, Image, TouchableOpacity, Dimensions } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { COLORS } from '../constants/theme';

const { width } = Dimensions.get('window');

const ActivityCard = ({ title, subtitle, bgColor, titleColor, subtitleColor, buttonBg, buttonIconColor, image, imageStyle }) => {
  return (
    <View style={[styles.card, { backgroundColor: bgColor }]}>
      <View style={styles.cardContent}>
        <Text style={[styles.cardTitle, { color: titleColor }]}>{title}</Text>
        <Text style={[styles.cardSubtitle, { color: subtitleColor }]}>{subtitle}</Text>
        
        <TouchableOpacity style={[styles.actionButton, { backgroundColor: buttonBg }]}>
           <MaterialIcons name="arrow-forward" size={20} color={buttonIconColor} />
        </TouchableOpacity>
      </View>
      
      <Image 
        source={{ uri: image }} 
        style={[styles.cardImage, imageStyle]}
        resizeMode="cover"
      />
    </View>
  );
};

const NewActivity = () => {
  return (
    <View style={styles.section}>
      <View style={styles.header}>
        <Text style={styles.title}>New Activity</Text>
        <TouchableOpacity>
          <Text style={styles.seeAll}>See All Suggestions</Text>
        </TouchableOpacity>
      </View>
      
      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        <ActivityCard 
          title={`Drinking\nTracker`}
          subtitle="Stay hydrated, it's nature's best refreshment!"
          bgColor={COLORS.primary}
          titleColor="black"
          subtitleColor="rgba(0,0,0,0.7)"
          buttonBg="white"
          buttonIconColor="black"
          image="https://lh3.googleusercontent.com/aida-public/AB6AXuBM5TojfJ_8QX3OzWdb9_NQTvPg8n5oqcp48DyMJEC30ElUTP2yOo5m3wXQJss7bP8772AWcZH0K59NgOncAklnRJBUR_04EijMT2l7GsBEsXXmko5w_V4FluP9qzIeqrx3qgJ8M-KJ27C1NbeoPSDvzWGLQxsQHgvrJkBSnEkmDuCvvqu257nVPPct-o0JIIPhd2TvTIjn7ckqVRH1Ryrm0WKz4WNLaa96Ao1gw8K-e-ig5BgiPY95womV10EIskCAE94VGABt3w"
          imageStyle={{ right: -20, bottom: 0, width: 140, height: 160 }}
        />
        
        <ActivityCard 
          title={`Daily\nExercise`}
          subtitle="Stay active, improve your health!"
          bgColor={COLORS.surfaceLight}
          titleColor={COLORS.textLight}
          subtitleColor="#6B7280"
          buttonBg={COLORS.primary}
          buttonIconColor="black"
          image="https://lh3.googleusercontent.com/aida-public/AB6AXuC9DZwhzyB6toThwgkrsTfZMmoFpMn_mzqQGI4qzm5TRRwXmZRTWamVH-PJzMim02N225q6YN20LRk4K-PIHARTMJBAgpMdhQMkzs7GAwIlGQjjzlP9HxHVYf_VMHq6lYyao3rMZpPdaSrZqGTARi_Cyb6pLWLKZvZlhYywu5YLfL2D85eQMt31aOJJPmwoFYo3xrWQD6Fj-xHtp9P8PKf1WiOmNruOwJHTgbnrA2IllG_Y278v2Lzg46NL48qsTMi73Dawmu5-UQ"
          imageStyle={{ right: -30, bottom: 0, width: 140, height: 160 }}
        />
        
        <ActivityCard 
          title={`Sleep\nTracker`}
          subtitle="Rest well, recover better!"
          bgColor="#1F2937"
          titleColor="white"
          subtitleColor="#D1D5DB"
          buttonBg={COLORS.primary}
          buttonIconColor="black"
          image="https://lh3.googleusercontent.com/aida-public/AB6AXuBg6Hs9Sx0O1k6jZdLfJpO_75xZOG8-S8WSD8vw6qBg_W7Xp95lj-X-96mtdwyWXBb6MuIDhmXGearivBQX32ahF8-_qjUXbinLljW84cUTEujUVf2UXft8C2mYUpSbATEjMUVN3grNqr_Fovls9nPCDwT0at8nxynw0XT-8MIZ445uGoAUXRCjoPIPyZrqgvUNs607bZ7pLBan21_tkBGrjg73lVex5l2JIn-ZynmUxMOTOzOxLKbfNgvwsG22udlGoKoQ4M53iQ"
          imageStyle={{ right: -20, bottom: 0, width: 140, height: 160, opacity: 0.8 }}
        />
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  section: {
    marginBottom: 24,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingHorizontal: 20,
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
  scrollContent: {
    paddingLeft: 20,
    paddingRight: 20,
    gap: 16,
    paddingBottom: 20, // ample space for shadows
  },
  card: {
    width: 280,
    height: 220,
    borderRadius: 24,
    padding: 20,
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  cardContent: {
    position: 'relative',
    zIndex: 10,
    width: '65%',
    height: '100%',
    justifyContent: 'space-between',
  },
  cardTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    lineHeight: 28,
  },
  cardSubtitle: {
    fontSize: 12,
    marginBottom: 16,
  },
  actionButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  cardImage: {
    position: 'absolute',
    borderRadius: 0,
    borderWidth: 0,
  }
});

export default NewActivity;
